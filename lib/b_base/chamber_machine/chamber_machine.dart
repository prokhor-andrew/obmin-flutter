import 'package:obmin_concept/a_foundation/machine.dart';
import 'package:obmin_concept/a_foundation/machine_factory.dart';
import 'package:obmin_concept/b_base/basic_machine/silo_machine.dart';
import 'package:obmin_concept/b_base/feature_machine/feature.dart';
import 'package:obmin_concept/b_base/feature_machine/feature_machine.dart';

extension ChamberMachine on MachineFactory {
  Machine<T, T Function(T), Loggable> chamber<T, Loggable>({
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

    return MachineFactory.shared.feature(
      id: id,
      feature: (id, logger) {
        return config(map(initial));
      },
    );
  }
}
