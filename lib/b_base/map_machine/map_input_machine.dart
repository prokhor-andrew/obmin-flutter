// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/machine.dart';
import 'package:obmin/a_foundation/machine_factory.dart';
import 'package:obmin/a_foundation/types/writer.dart';
import 'package:obmin/b_base/feature_machine/feature.dart';
import 'package:obmin/b_base/feature_machine/feature_machine.dart';
import 'package:obmin/b_base/feature_machine/outline.dart';

extension MapInputMachine<Input, Output, Loggable> on Machine<Input, Output, Loggable> {
  Machine<R, Output, Loggable> mapInput<R>(Input Function(R input) function) {
    return MachineFactory.shared.feature<(), Output, Input, R, Output, Loggable>(
      id: id,
      feature: () {
        Outline<(), Output, Input, R, Output, Loggable> outline() {
          return Outline.create(
            state: (),
            transit: (state, trigger, id) {
              switch (trigger) {
                case InternalFeatureEvent(value: final value):
                  return Writer(
                    OutlineTransition(
                      outline(),
                      effects: [
                        ExternalFeatureEvent<Input, Output>(value),
                      ],
                    ),
                  );
                case ExternalFeatureEvent(value: final value):
                  return Writer(
                    OutlineTransition(
                      outline(),
                      effects: [
                        InternalFeatureEvent<Input, Output>(function(value)),
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
