import 'package:obmin_concept/a_foundation/machine.dart';
import 'package:obmin_concept/a_foundation/machine_factory.dart';
import 'package:obmin_concept/a_foundation/machine_logger.dart';
import 'package:obmin_concept/b_base/basic_machine/basic_machine.dart';
import 'package:obmin_concept/b_base/feature_machine/feature.dart';

extension FeatureMachine on MachineFactory {
  Machine<ExtTrigger, ExtEffect, Loggable> feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable>({
    required String id,
    required Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> Function(
      String,
      MachineLogger<Loggable>,
    ) feature,
  }) {
    return MachineFactory.shared.create(
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

  Future<void> onChange(void Function(ExtEffect effect)? callback) async {
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
