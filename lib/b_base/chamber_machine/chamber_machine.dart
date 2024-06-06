// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/machine.dart';
import 'package:obmin/a_foundation/machine_factory.dart';
import 'package:obmin/a_foundation/types/writer.dart';
import 'package:obmin/b_base/chamber_machine/silo_machine.dart';
import 'package:obmin/b_base/feature_machine/feature.dart';
import 'package:obmin/b_base/feature_machine/feature_machine.dart';

extension ChamberMachine on MachineFactory {
  Machine<T, Writer<T, Loggable> Function(T), Loggable> chamber<T, Loggable>({
    required String id,
    required T initial,
    required Writer<Set<Silo<T, Loggable>>, Loggable> Function(T state) map,
  }) {
    Feature<(), Writer<T, Loggable> Function(T), (), T, Writer<T, Loggable> Function(T), Loggable> config(Set<Silo<T, Loggable>> machines) {
      return Feature.create(
        state: (),
        machines: machines,
        transit: (state, machines, trigger, machineId) {
          switch (trigger) {
            case InternalFeatureEvent<Writer<T, Loggable> Function(T), T>(value: final value):
              return Writer(
                FeatureTransition(
                  config(machines),
                  effects: [ExternalFeatureEvent(value)],
                ),
              );
            case ExternalFeatureEvent<Writer<T, Loggable> Function(T), T>(value: final value):
              return map(value).map((value) {
                return FeatureTransition(config(value));
              });
          }
        },
      );
    }

    return MachineFactory.shared.feature(
      id: id,
      feature: () {
        return map(initial).map((value) {
          return config(value);
        });
      },
    );
  }
}
