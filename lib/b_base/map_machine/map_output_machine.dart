// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/machine.dart';
import 'package:obmin/a_foundation/machine_factory.dart';
import 'package:obmin/a_foundation/types/writer.dart';
import 'package:obmin/b_base/feature_machine/feature.dart';
import 'package:obmin/b_base/feature_machine/feature_machine.dart';
import 'package:obmin/b_base/feature_machine/outline.dart';

extension MapOutputMachine<Input, Output, Loggable> on Machine<Input, Output, Loggable> {
  Machine<Input, R, Loggable> mapOutput<R>(R Function(Output output) function) {
    return MachineFactory.shared.feature<(), Output, Input, Input, R, Loggable>(
      id: id,
      feature: () {
        Outline<(), Output, Input, Input, R, Loggable> outline() {
          return Outline.create(
            state: (),
            transit: (state, trigger, id) {
              switch (trigger) {
                case InternalFeatureEvent(value: final value):
                  return Writer(
                    OutlineTransition(
                      outline(),
                      effects: [
                        ExternalFeatureEvent<Input, R>(function(value)),
                      ],
                    ),
                  );
                case ExternalFeatureEvent(value: final value):
                  return Writer(
                    OutlineTransition(
                      outline(),
                      effects: [
                        InternalFeatureEvent<Input, R>(value),
                      ],
                    ),
                  );
              }
            },
          );
        }

        return Writer(outline().asFeature({this}));
      },
    );
  }
}
