// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/channel/channel.dart';
import 'package:obmin/a_foundation/machine.dart';
import 'package:obmin/a_foundation/machine_factory.dart';
import 'package:obmin/a_foundation/machine_logger.dart';
import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/a_foundation/types/writer.dart';
import 'package:obmin/b_base/basic_machine/basic_machine.dart';
import 'package:obmin/b_base/feature_machine/feature.dart';

extension FeatureMachine on MachineFactory {
  Machine<ExtTrigger, ExtEffect, Loggable> feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable>({
    required String id,
    required Writer<Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable>, Loggable> Function() feature,
  }) {
    return MachineFactory.shared.create(
      id: id,
      onCreate: (id, logger) {
        return _FeatureHolder(
          id: id,
          initial: () {
            final writer = feature();

            for (final loggable in writer.logs) {
              logger.log(loggable);
            }

            return writer.value;
          },
          logger: logger,
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

final class _FeatureHolder<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> {
  final String _id;
  final MachineLogger<Loggable> _logger;
  final Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> Function() _initial;

  void Function(ExtEffect)? _callback;

  Set<Process<IntEffect>> _processes = {};

  final Channel<FeatureEvent<IntTrigger, ExtTrigger>, Loggable> _channel;
  ChannelTask<void>? _task;

  Writer<FeatureTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable>, Loggable> Function(
    FeatureEvent<IntTrigger, ExtTrigger>,
    String,
  )? _transit;

  _FeatureHolder({
    required String id,
    ChannelBufferStrategy<FeatureEvent<IntTrigger, ExtTrigger>, Loggable>? bufferStrategy,
    required MachineLogger<Loggable> logger,
    required Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> Function() initial,
  })  : _id = id,
        _logger = logger,
        _initial = initial,
        _channel = Channel(
          bufferStrategy: bufferStrategy ?? ChannelBufferStrategy.defaultStrategy(id: "default"),
          logger: logger.log,
        );

  Future<void> onChange(void Function(ExtEffect effect)? callback) async {
    this._callback = callback;

    if (callback != null) {
      final state = _initial();
      _transit = state.transit;
      _processes = state.machines.map((machine) {
        return machine.run(
          logger: _logger,
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

    final writer = transit(event, _id);
    final transition = writer.value;

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
        logger: _logger,
        onConsume: (output) async {
          await _channel.send(InternalFeatureEvent(output)).future;
        },
      );
    }).toSet();

    _processes = processesToAdd.union(processesToKeep);
    _transit = transition.feature.transit;

    for (final log in writer.logs) {
      _logger.log(log);
    }

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
