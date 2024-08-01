// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/channel/channel_lib.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine/machine_factory.dart';
import 'package:obmin/machine_ext/feature_machine/feature.dart';
import 'package:obmin/machine_ext/feature_machine/feature_machine.dart';
import 'package:obmin/machine_ext/feature_machine/outline.dart';
import 'package:obmin/types/optional.dart';

extension DistinctUntilChangedMachine<Input, Output> on Machine<Input, Output> {
  Machine<Input, Output> distinctUntilChangedInput({
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    Outline<Optional<Input>, Output, Input, Input, Output> outline(Optional<Input> state) {
      return Outline.create(
        state: state,
        transit: (state, trigger, _) {
          switch (trigger) {
            case InternalFeatureEvent(value: final value):
              return OutlineTransition(
                outline(state),
                effects: [ExternalFeatureEvent(value)],
              );
            case ExternalFeatureEvent(value: final value):
              return OutlineTransition(
                outline(Optional.some(value)),
                effects: state.map<List<FeatureEvent<Input, Output>>>((state) {
                  return state == value ? [] : [InternalFeatureEvent(value)];
                }).valueOr([InternalFeatureEvent(value)]),
              );
          }
        },
      );
    }

    return MachineFactory.shared.feature(
      id: id,
      onCreateFeature: () async {
        return outline(const Optional.none()).asFeature({this});
      },
      onDestroyFeature: (_) async {},
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }

  Machine<Input, Output> distinctUntilChangedOutput({
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    Outline<Optional<Output>, Output, Input, Input, Output> outline(Optional<Output> state) {
      return Outline.create(
        state: state,
        transit: (state, trigger, _) {
          switch (trigger) {
            case InternalFeatureEvent(value: final value):
              return OutlineTransition(
                outline(Optional.some(value)),
                effects: state.map<List<FeatureEvent<Input, Output>>>((state) {
                  return state == value ? [] : [ExternalFeatureEvent(value)];
                }).valueOr([ExternalFeatureEvent(value)]),
              );

            case ExternalFeatureEvent(value: final value):
              return OutlineTransition(
                outline(state),
                effects: [InternalFeatureEvent(value)],
              );
          }
        },
      );
    }

    return MachineFactory.shared.feature(
      id: id,
      onCreateFeature: () async {
        return outline(const Optional.none()).asFeature({this});
      },
      onDestroyFeature: (_) async {},
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}
