// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/channel/channel_lib.dart';
import 'package:obmin/machine/mealy.dart';
import 'package:obmin/machine/plan.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/option.dart';

final class Machine<Input, Output> {
  final ChannelBufferStrategy<Input>? inputBufferStrategy;
  final ChannelBufferStrategy<Output>? outputBufferStrategy;

  final String id;

  final (
    Future<void> Function(ChannelTask<bool> Function(Output output)? callback) onChange,
    Future<void> Function(Input input) onProcess,
  )
      Function() onCreate;

  const Machine({
    required this.id,
    this.inputBufferStrategy,
    this.outputBufferStrategy,
    required this.onCreate,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Machine<Input, Output> && runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  Process run({
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    required Future<void> Function(ChannelTask<bool> Function(Input input)? sender) onChange,
    required Future<void> Function(Output output) onConsume,
  }) {
    final onChangeExternal = onChange;

    final ChannelBufferStrategy<Output> actualOutputBufferStrategy = this.outputBufferStrategy ?? outputBufferStrategy ?? ChannelBufferStrategy.defaultStrategy(id: "default");
    final ChannelBufferStrategy<Input> actualInputBufferStrategy = this.inputBufferStrategy ?? inputBufferStrategy ?? ChannelBufferStrategy.defaultStrategy(id: "default");

    final Channel<Input> inputChannel = Channel(
      bufferStrategy: actualInputBufferStrategy,
    );

    final Channel<Output> outputChannel = Channel(
      bufferStrategy: actualOutputBufferStrategy,
    );

    bool isCancelled = false;
    ChannelTask<Option<Input>>? inputTask;
    ChannelTask<Option<Output>>? outputTask;

    Future(() async {
      if (isCancelled) {
        return;
      }

      final (onChangeInternal, onProcess) = onCreate();

      final future = Future.wait([
        Future(() async {
          while (true) {
            if (isCancelled) {
              break;
            }
            final ChannelTask<Option<Input>> task = inputChannel.next();
            inputTask = task;
            final value = await task.future;
            if (value.isNone()) {
              break;
            }
            await onProcess(value.force());
          }
        }),
        Future(() async {
          while (true) {
            if (isCancelled) {
              break;
            }
            final ChannelTask<Option<Output>> task = outputChannel.next();
            outputTask = task;
            final value = await task.future;
            if (value.isNone()) {
              break;
            }
            await onConsume(value.force());
          }
        }),
      ]);

      await Future.wait([
        onChangeInternal(outputChannel.send),
        onChangeExternal(inputChannel.send),
      ]);

      if (!isCancelled) {
        await future;
      }

      await Future.wait([
        onChangeInternal(null),
        onChangeExternal(null),
      ]);
    });

    return Process._(
      id: id,
      cancel: () {
        isCancelled = true;
        inputTask?.cancel();
        inputTask = null;
        outputTask?.cancel();
        outputTask = null;
      },
    );
  }

  static Machine<Input, Output> fromResource<Object, Input, Output>({
    required String id,
    required Object Function(String id) onCreate,
    required Future<void> Function(Object object, ChannelTask<bool> Function(Output output)? callback) onChange,
    required Future<void> Function(Object object, Input input) onProcess,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
  }) {
    return Machine<Input, Output>(
      id: id,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      onCreate: () {
        final Object object = onCreate(id);

        return (
          (callback) async {
            await onChange(object, callback);
          },
          (input) async {
            await onProcess(object, input);
          },
        );
      },
    );
  }

  static Machine<ExtTrigger, ExtEffect> fromMealy<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect>({
    required String id,
    required Future<Mealy<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect>> Function() onCreateMealy,
    required Future<void> Function(State state) onDestroyMealy,
    bool shouldWaitOnEffects = true,
    ChannelBufferStrategy<ExtTrigger>? inputBufferStrategy,
    ChannelBufferStrategy<ExtEffect>? outputBufferStrategy,
    ChannelBufferStrategy<Either<IntTrigger, ExtTrigger>>? internalBufferStrategy,
  }) {
    return Machine.fromResource<_MealyHolder<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect>, ExtTrigger, ExtEffect>(
      id: id,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      onCreate: (id) {
        return _MealyHolder(
          id: id,
          bufferStrategy: internalBufferStrategy,
          onCreate: onCreateMealy,
          onDestroy: onDestroyMealy,
          shouldWaitOnEffects: shouldWaitOnEffects,
        );
      },
      onChange: (object, callback) async {
        await object.onChange(callback);
      },
      onProcess: (object, input) async {
        await object.onProcess(input);
      },
    );
  }

  static Machine<Never, T> fromProducer<Object, T>({
    required String id,
    required Object Function(void Function(T response) callback) onStart,
    required void Function(Object object) onStop,
    ChannelBufferStrategy<T>? bufferStrategy,
  }) {
    return Machine.fromResource<_ProducerHolder<Object>, Never, T>(
      id: id,
      onCreate: (id) {
        return _ProducerHolder<Object>();
      },
      onChange: (object, callback) async {
        if (callback != null) {
          object.object = onStart((output) async {
            await callback(output).future;
          });
        } else {
          onStop(object.object as Object);
          object.object = null;
        }
      },
      onProcess: (object, input) async {
        // do nothing
      },
      outputBufferStrategy: bufferStrategy,
    );
  }

  static Machine<Never, Res> fromStream<Res>({
    required String id,
    required Stream<Res> Function() stream,
  }) {
    return Machine.fromProducer<StreamSubscription<Res>, Res>(
      id: id,
      onStart: (callback) {
        return stream().listen(callback);
      },
      onStop: (sub) {
        sub.cancel();
      },
    );
  }

  Machine<Never, Res> fromFuture<Res>({
    required String id,
    required Future<Res> Function() future,
  }) {
    return Machine.fromStream<Res>(
      id: id,
      stream: () {
        return future().asStream();
      },
    );
  }

  Machine<R, Output> lmap<R>(
    Input Function(R input) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<R>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<Either<Output, R>>? internalBufferStrategy,
  }) {
    return Machine.fromMealy<(), Output, Input, R, Output>(
      id: id,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
      onCreateMealy: () async {
        Plan<(), Output, Input, R, Output> outline() {
          return Plan.create(
            state: (),
            transit: (state, trigger, id) {
              return trigger.match(
                (value) {
                  return PlanTransition(
                    outline(),
                    effects: [
                      Either.right<Input, Output>(value),
                    ].lock,
                  );
                },
                (value) {
                  return PlanTransition(
                    outline(),
                    effects: [
                      Either.left<Input, Output>(function(value)),
                    ].lock,
                  );
                },
              );
            },
          );
        }

        return outline().asMealy({this}.lock);
      },
      onDestroyMealy: (_) async {},
      shouldWaitOnEffects: shouldWaitOnEffects,
    );
  }

  Machine<Input, R> rmap<R>(
    R Function(Output output) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<R>? outputBufferStrategy,
    ChannelBufferStrategy<Either<Output, Input>>? internalBufferStrategy,
  }) {
    return Machine.fromMealy<(), Output, Input, Input, R>(
      id: id,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
      onCreateMealy: () async {
        Plan<(), Output, Input, Input, R> outline() {
          return Plan.create(
            state: (),
            transit: (state, trigger, id) {
              return trigger.match(
                (value) {
                  return PlanTransition(
                    outline(),
                    effects: [
                      Either.right<Input, R>(function(value)),
                    ].lock,
                  );
                },
                (value) {
                  return PlanTransition(
                    outline(),
                    effects: [
                      Either.left<Input, R>(value),
                    ].lock,
                  );
                },
              );
            },
          );
        }

        return outline().asMealy({this}.lock);
      },
      onDestroyMealy: (_) async {},
      shouldWaitOnEffects: shouldWaitOnEffects,
    );
  }

  static Machine<Input, Output> fromPool<Input, Output, Helper>({
    required String id,
    required Future<Helper> Function() onCreateHelper,
    required Future<void> Function(Helper helper) onDestroyHelper,
    required ISet<Machine<Never, Output>> Function(Helper helper) initial,
    required ISet<Machine<Never, Output>> Function(Helper helper, Input input) map,
    bool shouldWaitOnEffects = true,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<Either<Output, Input>>? internalBufferStrategy,
  }) {
    Mealy<Helper, Output, Never, Input, Output> config(Helper helper, ISet<Machine<Never, Output>> machines) {
      return Mealy.create(
        state: helper,
        machines: machines,
        transit: (state, machines, trigger, machineId) {
          return trigger.match(
            (value) {
              return MealyTransition(
                config(state, machines),
                effects: [Either.right<Never, Output>(value)].lock,
              );
            },
            (value) {
              return MealyTransition(config(state, map(state, value)));
            },
          );
        },
      );
    }

    return Machine.fromMealy(
      id: id,
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
      onCreateMealy: () async {
        final helper = await onCreateHelper();
        final initialMachines = initial(helper);
        return config(helper, initialMachines);
      },
      onDestroyMealy: (helper) async {
        await onDestroyHelper(helper);
      },
    );
  }

  static Machine<State, Func<State, State>> fromPoolX<State, Helper>({
    required String id,
    required Future<Helper> Function() onCreateHelper,
    required Future<void> Function(Helper helper) onDestroyHelper,
    required State initial,
    required ISet<Machine<Never, Func<State, State>>> Function(Helper helper, State state) map,
    bool isDistinctUntilChangedOn = true,
    bool shouldWaitOnEffects = true,
    ChannelBufferStrategy<State>? inputBufferStrategy,
    ChannelBufferStrategy<Func<State, State>>? outputBufferStrategy,
    ChannelBufferStrategy<Either<Func<State, State>, State>>? internalBufferStrategy,
  }) {
    final machine = Machine.fromPool<State, Func<State, State>, Helper>(
      id: id,
      onCreateHelper: onCreateHelper,
      onDestroyHelper: onDestroyHelper,
      initial: (helper) {
        return map(helper, initial);
      },
      map: map,
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
    return isDistinctUntilChangedOn ? machine.distinctUntilChangedInput(shouldWaitOnEffects: false) : machine;
  }

  Machine<Input, Output> distinctUntilChangedInput({
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<Either<Output, Input>>? internalBufferStrategy,
  }) {
    Plan<Option<Input>, Output, Input, Input, Output> outline(Option<Input> state) {
      return Plan.create(
        state: state,
        transit: (state, trigger, _) {
          return trigger.match(
            (value) {
              return PlanTransition(
                outline(state),
                effects: [Either.right<Input, Output>(value)].lock,
              );
            },
            (value) {
              return PlanTransition(
                outline(Option.some(value)),
                effects: state.map<IList<Either<Input, Output>>>((state) {
                  return state == value ? const IList.empty() : [Either.left<Input, Output>(value)].lock;
                }).valueOr([Either.left<Input, Output>(value)].lock),
              );
            },
          );
        },
      );
    }

    return Machine.fromMealy(
      id: id,
      onCreateMealy: () async {
        return outline(Option.none()).asMealy({this}.lock);
      },
      onDestroyMealy: (_) async {},
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }

  Machine<Input, Output> distinctUntilChangedOutput({
    required bool shouldWaitOnEffects,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<Either<Output, Input>>? internalBufferStrategy,
  }) {
    Plan<Option<Output>, Output, Input, Input, Output> outline(Option<Output> state) {
      return Plan.create(
        state: state,
        transit: (state, trigger, _) {
          return trigger.match(
            (value) {
              return PlanTransition(
                outline(Option.some(value)),
                effects: state.map<IList<Either<Input, Output>>>((state) {
                  return state == value ? const IList.empty() : [Either.right<Input, Output>(value)].lock;
                }).valueOr([Either.right<Input, Output>(value)].lock),
              );
            },
            (value) {
              return PlanTransition(
                outline(state),
                effects: [Either.left<Input, Output>(value)].lock,
              );
            },
          );
        },
      );
    }

    return Machine.fromMealy(
      id: id,
      onCreateMealy: () async {
        return outline(Option.none()).asMealy({this}.lock);
      },
      onDestroyMealy: (_) async {},
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}

final class Process {
  final String id;
  final void Function() _cancel;

  const Process._({
    required this.id,
    required void Function() cancel,
  }) : _cancel = cancel;

  void cancel() {
    _cancel();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Process && runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return "Process{ id=$id }";
  }
}

final class _ProducerHolder<Object> {
  Object? object;
}

final class _MealyHolder<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect> {
  final String _id;
  final Future<Mealy<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect>> Function() _onCreate;
  final Future<void> Function(State state) _onDestroy;
  final bool shouldWaitOnEffects;

  bool _isCancelled = false;

  ChannelTask<bool> Function(ExtEffect)? _callback;

  ISet<Process> _processes = const ISet.empty();
  final Map<String, ChannelTask<bool> Function(IntEffect)> _senders = {};

  final Channel<Either<IntTrigger, ExtTrigger>> _channel;
  ChannelTask<Option<Either<IntTrigger, ExtTrigger>>>? _task;

  late State _state;

  MealyTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect> Function(
    Either<IntTrigger, ExtTrigger>,
    String,
  )? _transit;

  _MealyHolder({
    required String id,
    ChannelBufferStrategy<Either<IntTrigger, ExtTrigger>>? bufferStrategy,
    required Future<Mealy<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect>> Function() onCreate,
    required Future<void> Function(State state) onDestroy,
    required this.shouldWaitOnEffects,
  })  : _id = id,
        _onCreate = onCreate,
        _onDestroy = onDestroy,
        _channel = Channel(
          bufferStrategy: bufferStrategy ?? ChannelBufferStrategy.defaultStrategy(id: "default"),
        );

  Future<void> onChange(ChannelTask<bool> Function(ExtEffect effect)? callback) async {
    this._callback = callback;

    if (callback != null) {
      final state = await _onCreate();
      _state = state.state;
      _transit = state.transit;

      _processes = state.machines.map((machine) {
        return machine.run(
          onChange: (sender) async {
            if (sender != null) {
              _senders[machine.id] = sender;
            } else {
              _senders.remove(machine.id);
            }
          },
          onConsume: (event) async {
            await _channel.send(Either.left(event)).future;
          },
        );
      }).toISet();

      Future(() async {
        while (true) {
          if (_isCancelled) {
            break;
          }
          final ChannelTask<Option<Either<IntTrigger, ExtTrigger>>> task = _channel.next();
          _task = task;
          final value = await task.future;

          if (value.isNone()) {
            break;
          }

          await _handle(value.force());
        }
      });
    } else {
      _isCancelled = true;
      _task?.cancel();
      _task = null;
      _transit = null;
      for (final process in _processes) {
        process.cancel();
      }
      _processes = const ISet.empty();

      await _onDestroy(_state);
    }
  }

  Future<void> onProcess(ExtTrigger input) async {
    await _channel.send(Either.right(input)).future;
  }

  Future<void> _handle(Either<IntTrigger, ExtTrigger> event) async {
    final transit = _transit;
    if (transit == null) {
      return;
    }
    final transition = transit(event, _id);

    final resultingMachines = transition.mealy.machines;

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
    }).toISet();

    for (final process in processesToRemove) {
      process.cancel();
    }

    final processesToAdd = machinesToAdd.map((machine) {
      return machine.run(
        onChange: (sender) async {
          if (sender != null) {
            _senders[machine.id] = sender;
          } else {
            _senders.remove(machine.id);
          }
        },
        onConsume: (output) async {
          await _channel.send(Either.left(output)).future;
        },
      );
    }).toISet();

    _processes = processesToAdd.union(processesToKeep);
    _state = transition.mealy.state;
    _transit = transition.mealy.transit;

    final effects = transition.effects;

    final effectsFuture = Future.wait<void>([
      Future(() async {
        for (final effect in effects) {
          await effect.match(
            (_) => Future.sync(() {}),
            (value) async {
              final callback = _callback;
              if (callback != null) {
                await callback(value).future;
              }
            },
          );
        }
      }),
      Future.wait(
        _senders.values.map((sender) {
          return Future(() async {
            for (final effect in effects) {
              await effect.match(
                (value) async {
                  await sender(value).future;
                },
                (_) => Future.sync(() {}),
              );
            }
          });
        }),
      ),
    ]);

    if (shouldWaitOnEffects) {
      await effectsFuture;
    }
  }
}

extension _OptionForce<A> on Option<A> {
  A force() {
    return match<A>(
      () => throw "Option.none is being forcefully unwrapped",
      idfunc,
    );
  }
}
