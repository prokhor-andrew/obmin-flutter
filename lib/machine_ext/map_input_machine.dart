// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine/machine_factory.dart';
import 'package:obmin/machine_ext/feature_machine/feature.dart';
import 'package:obmin/machine_ext/feature_machine/feature_machine.dart';
import 'package:obmin/machine_ext/feature_machine/outline.dart';
import 'package:obmin/channel/channel_lib.dart';

extension MapInputMachine<Input, Output> on Machine<Input, Output> {
  Machine<R, Output> mapInput<R>(Input Function(R input) function, {
    ChannelBufferStrategy<R>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, R>>? internalBufferStrategy,
  }) {
    return MachineFactory.shared.feature<(), Output, Input, R, Output>(
      id: id,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
      onCreateFeature: () async {
        Outline<(), Output, Input, R, Output> outline() {
          return Outline.create(
            state: (),
            transit: (state, trigger, id) {
              switch (trigger) {
                case InternalFeatureEvent(value: final value):
                  return OutlineTransition(
                    outline(),
                    effects: [
                      ExternalFeatureEvent<Input, Output>(value),
                    ],
                  );
                case ExternalFeatureEvent(value: final value):
                  return OutlineTransition(
                    outline(),
                    effects: [
                      InternalFeatureEvent<Input, Output>(function(value)),
                    ],
                  );
              }
            },
          );
        }

        return outline().asFeature({this});
      },
      onDestroyFeature: (_) async {},
    );
  }
}
