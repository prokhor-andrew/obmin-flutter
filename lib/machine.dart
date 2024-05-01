import 'package:obmin_concept/machine_logger.dart';

import 'feature.dart';

final class Machine<Input, Output, Loggable> {
  final String id;

  final (
    void Function(void Function(Output output)? callback) onChange,
    Future<void> Function(Input input) onProcess,
  )
      Function(MachineLogger<Loggable> logger) onCreate;

  Machine({
    required this.id,
    required this.onCreate,
  });

  static Machine<T, T Function(T), Loggable> chamber<T, Loggable>({
    required String id,
    required T initial,
    required Set<Silo<T, Loggable>> Function(T state) map,
  }) {
    Feature<(), T Function(T), (), T, T Function(T), Loggable> config(Set<Silo<T, Loggable>> machines) {
      return Feature.create(
        state: (),
        machines: machines,
        transit: (extras, trigger) {
          switch (trigger) {
            case InternalFeatureEvent<T Function(T), T>(value: final value):
              return FeatureTransition(config(extras.machines), effects: [ExternalFeatureEvent(value)]);
            case ExternalFeatureEvent<T Function(T), T>(value: final value):
              return FeatureTransition(config(map(value)));
          }
        },
      );
    }

    return Machine.feature(
      id: id,
      feature: (id, logger) {
        return config(map(initial));
      },
    );
  }

  static Silo<T, Loggable> silo<Object, T, Loggable>({
    required String id,
    required Object Function(void Function(T Function(T) transition) callback) onStart,
    required void Function(Object object) onStop,
  }) {
    return Machine.create(
      id: id,
      onCreate: (id, logger) {
        return _Holder<Object>();
      },
      onChange: (object, callback) {
        if (callback != null) {
          object.object = onStart(callback);
        } else {
          onStop(object.object as Object);
          object.object = null;
        }
      },
      onProcess: (object, input) async {
        // do nothing
      },
    );
  }

  static Machine<ExtTrigger, ExtEffect, Loggable> feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable>({
    required String id,
    required Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> Function(
      String,
      MachineLogger<Loggable>,
    ) feature,
  }) {
    return Machine.create(
      id: id,
      onCreate: (id, logger) {
        return _FeatureHolder(
          id: id,
          initial: () {
            return feature(id, logger);
          },
          logger: logger,
        );
      },
      onChange: (object, callback) {
        object.onChange(callback);
      },
      onProcess: (object, input) async {
        await object.onProcess(input);
      },
    );
  }

  static Machine<Input, Output, Loggable> create<Object, Input, Output, Loggable>({
    required String id,
    required Object Function(String id, MachineLogger<Loggable> logger) onCreate,
    required void Function(Object object, void Function(Output output)? callback) onChange,
    required Future<void> Function(Object object, Input input) onProcess,
  }) {
    return Machine(
      id: id,
      onCreate: (logger) {
        final object = onCreate(id, logger);

        return (
          (callback) {
            onChange(object, callback);
          },
          (input) async {
            await onProcess(object, input);
          },
        );
      },
    );
  }

  Machine<R, Output, Loggable> transformInput<R>(Input Function(R input) transform) {
    return Machine(
      id: id,
      onCreate: (logger) {
        final (onChange, onProcess) = onCreate(logger);

        return (
          onChange,
          (input) async {
            await onProcess(transform(input));
          },
        );
      },
    );
  }

  Machine<Input, R, Loggable> transformOutput<R>(R Function(Output output) transform) {
    return Machine(
      id: id,
      onCreate: (logger) {
        final (onChange, onProcess) = onCreate(logger);

        return (
          (callback) {
            if (callback != null) {
              onChange(
                (output) {
                  callback(transform(output));
                },
              );
            } else {
              onChange(null);
            }
          },
          onProcess,
        );
      },
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Machine<Input, Output, Loggable> && runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  Process<Input, Output, Loggable> run({
    required MachineLogger<Loggable> onLog,
    required Future<void> Function(Output output) onConsume,
  }) {
    final (onChange, onProcess) = this.onCreate(onLog);

    return Process._(
      id: id,
      onChange: onChange,
      onProcess: onProcess,
      onConsume: onConsume,
    );
  }
}

final class Process<Input, Output, Loggable> {
  final String id;

  final _ProcessQueue<Input> _inputQueue;
  final _ProcessQueue<Output> _outputQueue;

  final void Function(void Function(Output output)? callback) _onChange;
  final Future<void> Function(Input input) _onProcess;

  Process._({
    required this.id,
    required void Function(void Function(Output output)? callback) onChange,
    required Future<void> Function(Input input) onProcess,
    required Future<void> Function(Output output) onConsume,
  })  : _onChange = onChange,
        _onProcess = onProcess,
        _inputQueue = _ProcessQueue(),
        _outputQueue = _ProcessQueue() {
    onChange((output) {
      this._outputQueue.schedule(() async {
        await onConsume(output);
      });
    });
  }

  void send(Input input) {
    this._inputQueue.schedule(() async {
      await this._onProcess(input);
    });
  }

  void cancel() {
    this._inputQueue.cancel();
    this._outputQueue.cancel();
    this._onChange(null);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Process<Input, Output, Loggable> && runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

final class _ProcessQueue<T> {
  List<Future<void> Function()> _array = [];
  Future<void>? _executor;

  _ProcessQueue();

  void schedule(Future<void> Function() func) {
    this._array.add(func);

    if (this._executor == null) {
      this._executor = this._execute().whenComplete(() {
        this._executor = null;
      });
    }
  }

  void cancel() {
    this._array = [];
    this._executor = null;
  }

  Future<void> _execute() async {
    while (this._array.isNotEmpty) {
      await this._array[0]();

      if (this._array.isNotEmpty) {
        this._array.removeAt(0);
      }
    }
  }
}

final class _FeatureHolder<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> {
  final String _id;
  final MachineLogger<Loggable> _logger;
  final Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> Function() _initial;

  void Function(ExtEffect)? _callback;

  Set<Process<IntEffect, IntTrigger, Loggable>> _processes = {};

  FeatureTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> Function(
    FeatureEvent<IntTrigger, ExtTrigger>,
    String,
    MachineLogger<Loggable>,
  )? _transit;

  _FeatureHolder({
    required String id,
    required MachineLogger<Loggable> logger,
    required Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> Function() initial,
  })  : _id = id,
        _logger = logger,
        _initial = initial;

  void onChange(void Function(ExtEffect effect)? callback) {
    this._callback = callback;

    if (callback != null) {
      final state = _initial();
      _transit = state.transit;
      _processes = state.machines.map((machine) {
        return machine.run(
          onLog: _logger,
          onConsume: (event) async {
            await _handle(InternalFeatureEvent(event));
          },
        );
      }).toSet();
    } else {
      _transit = null;
      for (final process in _processes) {
        process.cancel();
      }
      _processes = {};
    }
  }

  Future<void> onProcess(ExtTrigger input) async {
    await _handle(ExternalFeatureEvent(input));
  }

  Future<void> _handle(FeatureEvent<IntTrigger, ExtTrigger> event) async {
    final transit = _transit;
    if (transit == null) {
      return;
    }

    final transition = transit(event, _id, _logger);

    final resultingMachines = transition.feature.machines;

    final machinesToAdd = resultingMachines.where((machine) {
      return _processes.where((process) {
            return process.id == machine.id;
          }).firstOrNull ==
          null;
    });

    final processesToRemove = _processes.where((process) {
      return resultingMachines.where((machine) {
            return machine.id == process.id;
          }).firstOrNull ==
          null;
    });

    final processesToKeep = _processes.where((process) {
      return machinesToAdd.where(
                (machine) {
                  return machine.id == process.id;
                },
              ).firstOrNull ==
              null &&
          processesToRemove.where(
                (processToRemove) {
                  return processToRemove.id == process.id;
                },
              ).firstOrNull ==
              null;
    }).toSet();

    for (final process in processesToRemove) {
      process.cancel();
    }

    final processesToAdd = machinesToAdd.map((machine) {
      return machine.run(
        onLog: _logger,
        onConsume: (output) async {
          await _handle(InternalFeatureEvent(output));
        },
      );
    }).toSet();

    _processes = processesToAdd.union(processesToKeep);
    _transit = transition.feature.transit;

    final effects = transition.effects;

    await Future.wait([
      Future(() {
        for (final effect in effects) {
          switch (effect) {
            case InternalFeatureEvent<IntEffect, ExtEffect>():
              break;
            case ExternalFeatureEvent<IntEffect, ExtEffect>(value: final value):
              final callback = _callback;
              if (callback != null) {
                callback(value);
              }
              break;
          }
        }
      }),
      Future.wait(
        processesToKeep.map((process) {
          return Future(() {
            for (final effect in effects) {
              switch (effect) {
                case InternalFeatureEvent<IntEffect, ExtEffect>(value: final value):
                  process.send(value);
                  break;
                case ExternalFeatureEvent<IntEffect, ExtEffect>():
                  break;
              }
            }
          });
        }),
      ),
    ]);
  }
}

final class _Holder<Object> {
  Object? object;
}

typedef Silo<T, Loggable> = Machine<(), T Function(T), Loggable>;
