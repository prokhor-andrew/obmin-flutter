// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/channel/channel_lib.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine/machine_factory.dart';
import 'package:obmin/machine_ext/basic_machine.dart';
import 'package:obmin/machine_ext/feature_machine/feature.dart';
import 'package:obmin/types/optional.dart';

extension FeatureMachineExtension on MachineFactory {
  Machine<ExtTrigger, ExtEffect> feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect>({
    required String id,
    required Future<Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect>> Function() onCreateFeature,
    required Future<void> Function(State state) onDestroyFeature,
    bool shouldWaitOnEffects = true,
    void Function(String loggable)? onLog,
    ChannelBufferStrategy<ExtTrigger>? inputBufferStrategy,
    ChannelBufferStrategy<ExtEffect>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<IntTrigger, ExtTrigger>>? internalBufferStrategy,
  }) {
    return MachineFactory.shared.basic<_FeatureHolder<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect>, ExtTrigger, ExtEffect>(
      id: id,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      onCreate: (id) {
        return _FeatureHolder(
          id: id,
          bufferStrategy: internalBufferStrategy,
          onCreate: onCreateFeature,
          onDestroy: onDestroyFeature,
          shouldWaitOnEffects: shouldWaitOnEffects,
          onLog: onLog,
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
}

final class _FeatureHolder<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect> {
  final String _id;
  final Future<Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect>> Function() _onCreate;
  final Future<void> Function(State state) _onDestroy;
  final void Function(String loggable)? _onLog;
  final bool shouldWaitOnEffects;

  bool _isCancelled = false;

  ChannelTask<bool> Function(ExtEffect)? _callback;

  Set<Process<IntEffect>> _processes = {};
  final Map<String, ChannelTask<bool> Function(IntEffect)> _senders = {};

  final Channel<FeatureEvent<IntTrigger, ExtTrigger>> _channel;
  ChannelTask<Optional<FeatureEvent<IntTrigger, ExtTrigger>>>? _task;

  late State _state;

  FeatureTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect> Function(
    FeatureEvent<IntTrigger, ExtTrigger>,
    String,
  )? _transit;

  _FeatureHolder({
    required String id,
    ChannelBufferStrategy<FeatureEvent<IntTrigger, ExtTrigger>>? bufferStrategy,
    required Future<Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect>> Function() onCreate,
    required Future<void> Function(State state) onDestroy,
    required void Function(String loggable)? onLog,
    required this.shouldWaitOnEffects,
  })  : _id = id,
        _onCreate = onCreate,
        _onDestroy = onDestroy,
        _onLog = onLog,
        _channel = Channel(
          bufferStrategy: bufferStrategy ?? ChannelBufferStrategy.defaultStrategy(id: "default"),
        );

  void _log() {
    final onLog = _onLog;
    if (onLog != null) {
      onLog("FeatureMachine<$State, $IntTrigger, $IntEffect, $ExtTrigger, $ExtEffect> { id=$_id, state=$_state, process=$_processes }");
    }
  }

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
            await _channel.send(InternalFeatureEvent(event)).future;
          },
        );
      }).toSet();

      _log();

      Future(() async {
        while (true) {
          if (_isCancelled) {
            break;
          }
          final ChannelTask<Optional<FeatureEvent<IntTrigger, ExtTrigger>>> task = _channel.next();
          _task = task;
          final value = await task.future;

          if (value.isNone) {
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
      _processes = {};

      await _onDestroy(_state);

      _log();
    }
  }

  Future<void> onProcess(ExtTrigger input) async {
    await _channel.send(ExternalFeatureEvent(input)).future;
  }

  Future<void> _handle(FeatureEvent<IntTrigger, ExtTrigger> event) async {
    final transit = _transit;
    if (transit == null) {
      return;
    }
    final transition = transit(event, _id);

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
        onChange: (sender) async {
          if (sender != null) {
            _senders[machine.id] = sender;
          } else {
            _senders.remove(machine.id);
          }
        },
        onConsume: (output) async {
          await _channel.send(InternalFeatureEvent(output)).future;
        },
      );
    }).toSet();

    _processes = processesToAdd.union(processesToKeep);
    _state = transition.feature.state;
    _transit = transition.feature.transit;

    _log();

    final effects = transition.effects;

    final effectsFuture = Future.wait<void>([
      Future(() async {
        for (final effect in effects) {
          switch (effect) {
            case InternalFeatureEvent<IntEffect, ExtEffect>():
              break;
            case ExternalFeatureEvent<IntEffect, ExtEffect>(value: final value):
              final callback = _callback;
              if (callback != null) {
                await callback(value).future;
              }
              break;
          }
        }
      }),
      Future.wait(
        _senders.values.map((sender) {
          return Future(() async {
            for (final effect in effects) {
              switch (effect) {
                case InternalFeatureEvent<IntEffect, ExtEffect>(value: final value):
                  await sender(value).future;
                  break;
                case ExternalFeatureEvent<IntEffect, ExtEffect>():
                  break;
              }
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
