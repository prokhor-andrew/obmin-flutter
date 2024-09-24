// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/channel/channel_lib.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine/machine_factory.dart';
import 'package:obmin/machine_ext/feature_machine/feature.dart';
import 'package:obmin/machine_ext/feature_machine/feature_machine.dart';
import 'package:obmin/machine_ext/feature_machine/outline.dart';
import 'package:obmin/machine_ext/silo_machine.dart';

extension MapOutputMachineExtension<Input, Output> on Machine<Input, Output> {
  Machine<Input, R> mapOutput<R>(
    R Function(Output output) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<R>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    return MachineFactory.shared.feature<(), Output, Input, Input, R>(
      id: id,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
      onCreateFeature: () async {
        Outline<(), Output, Input, Input, R> outline() {
          return Outline.create(
            state: (),
            transit: (state, trigger, id) {
              switch (trigger) {
                case InternalFeatureEvent(value: final value):
                  return OutlineTransition(
                    outline(),
                    effects: [
                      ExternalFeatureEvent<Input, R>(function(value)),
                    ],
                  );
                case ExternalFeatureEvent(value: final value):
                  return OutlineTransition(
                    outline(),
                    effects: [
                      InternalFeatureEvent<Input, R>(value),
                    ],
                  );
              }
            },
          );
        }

        return outline().asFeature({this});
      },
      onDestroyFeature: (_) async {},
      shouldWaitOnEffects: shouldWaitOnEffects,
    );
  }
}

extension MapSiloExtension<T> on Silo<T> {
  Silo<R> map<R>(
    R Function(T value) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Never>? inputBufferStrategy,
    ChannelBufferStrategy<R>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<T, Never>>? internalBufferStrategy,
  }) {
    return mapOutput<R>(
      function,
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}
