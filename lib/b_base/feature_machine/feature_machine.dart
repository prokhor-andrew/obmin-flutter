// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/channel/channel.dart';
import 'package:obmin/a_foundation/machine.dart';
import 'package:obmin/a_foundation/machine_factory.dart';
import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/b_base/basic_machine/basic_machine.dart';
import 'package:obmin/b_base/feature_machine/feature.dart';

extension FeatureMachine on MachineFactory {
  Machine<ExtTrigger, ExtEffect> feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect>({
    required String id,
    required Future<Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect>> Function() onCreateFeature,
    required Future<void> Function(State state) onDestroyFeature,
    ChannelBufferStrategy<ExtTrigger>? inputBufferStrategy,
    ChannelBufferStrategy<ExtEffect>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<IntTrigger, ExtTrigger>>? internalBufferStrategy,
  }) {
    return MachineFactory.shared.create<_FeatureHolder<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect>, ExtTrigger, ExtEffect>(
      id: id,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      onCreate: (id) {
        return _FeatureHolder(
          id: id,
          bufferStrategy: internalBufferStrategy,
          onCreate: onCreateFeature,
          onDestroy: onDestroyFeature,
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

  void Function(ExtEffect)? _callback;

  Set<Process<IntEffect>> _processes = {};

  final Channel<FeatureEvent<IntTrigger, ExtTrigger>> _channel;
  ChannelTask<void>? _task;

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
  })  : _id = id,
        _onCreate = onCreate,
        _onDestroy = onDestroy,
        _channel = Channel(
          bufferStrategy: bufferStrategy ?? ChannelBufferStrategy.defaultStrategy(id: "default"),
        );

  Future<void> onChange(void Function(ExtEffect effect)? callback) async {
    this._callback = callback;

    if (callback != null) {
      final state = await _onCreate();
      _state = state.state;
      _transit = state.transit;

      _processes = state.machines.map((machine) {
        return machine.run(
          onConsume: (event) async {
            await _channel.send(InternalFeatureEvent(event)).future;
          },
        );
      }).toSet();

      _task = _channel.next().map((future) {
        return Future(() async {
          while (true) {
            final result = await future;
            if (result is None<FeatureEvent<IntTrigger, ExtTrigger>>) {
              break;
            }
            await _handle(result.force());
          }
        });
      });
    } else {
      _task?.cancel();
      _task = null;
      _transit = null;
      for (final process in _processes) {
        process.cancel();
      }
      _processes = {};

      await _onDestroy(_state);
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
        onConsume: (output) async {
          await _channel.send(InternalFeatureEvent(output)).future;
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
