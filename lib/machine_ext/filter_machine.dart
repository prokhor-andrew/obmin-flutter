// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/channel/channel_lib.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine/machine_factory.dart';
import 'package:obmin/machine_ext/feature_machine/feature.dart';
import 'package:obmin/machine_ext/feature_machine/feature_machine.dart';
import 'package:obmin/machine_ext/feature_machine/outline.dart';

extension FilterMachine<Input, Output> on Machine<Input, Output> {
  Machine<Input, Output> filter({
    required bool Function(Input input) input,
    required bool Function(Output output) output,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    Outline<(), Output, Input, Input, Output> outline() {
      return Outline.create(
        state: (),
        transit: (state, trigger, _) {
          switch (trigger) {
            case InternalFeatureEvent(value: final value):
              return OutlineTransition(
                outline(),
                effects: output(value) ? [ExternalFeatureEvent(value)] : [],
              );

            case ExternalFeatureEvent(value: final value):
              return OutlineTransition(
                outline(),
                effects: input(value) ? [InternalFeatureEvent(value)] : [],
              );
          }
        },
      );
    }

    return MachineFactory.shared.feature(
      id: id,
      onCreateFeature: () async {
        return outline().asFeature({this});
      },
      onDestroyFeature: (_) async {},
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }

  Machine<Input, Output> filterInput(
    bool Function(Input input) function, {
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    return filter(
      input: function,
      output: (_) => true,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }

  Machine<Input, Output> filterOutput(
    bool Function(Output output) function, {
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    return filter(
      output: function,
      input: (_) => true,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}
