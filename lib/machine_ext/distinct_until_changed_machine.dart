// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/channel/channel_lib.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine_ext/feature_machine/feature.dart';
import 'package:obmin/machine_ext/filter_machine.dart';
import 'package:obmin/machine_ext/silo_machine.dart';
import 'package:obmin/types/optional.dart';

extension DistinctUntilChangedMachineExtension<Input, Output> on Machine<Input, Output> {
  Machine<Input, Output> distinctUntilChangedInput({
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    return filterInputWithState<Optional<Input>>(
      Optional.none(),
      (state, input) {
        return (
          Optional.some(input),
          state.map((oldInput) => oldInput != input).valueOr(true),
        );
      },
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }

  Machine<Input, Output> distinctUntilChangedOutput({
    required bool shouldWaitOnEffects,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    return filterOutputWithState<Optional<Output>>(
      Optional.none(),
      (state, output) {
        return (
          Optional.some(output),
          state.map((oldInput) => oldInput != output).valueOr(true),
        );
      },
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}

extension DistinctUntilChangedSiloExtension<T> on Silo<T> {
  Silo<T> distinctUntilChanged({
    required bool shouldWaitOnEffects,
    ChannelBufferStrategy<T>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<T, Never>>? internalBufferStrategy,
  }) {
    return distinctUntilChangedOutput(
      shouldWaitOnEffects: shouldWaitOnEffects,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}
