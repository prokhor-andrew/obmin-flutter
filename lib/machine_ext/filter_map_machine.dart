// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/channel/channel_lib.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine/machine_factory.dart';
import 'package:obmin/machine_ext/feature_machine/feature.dart';
import 'package:obmin/machine_ext/feature_machine/feature_machine.dart';
import 'package:obmin/machine_ext/feature_machine/outline.dart';
import 'package:obmin/machine_ext/silo_machine.dart';
import 'package:obmin/fp/optional.dart';

extension FilterMapMachineExtension<Input, Output> on Machine<Input, Output> {
  Machine<R, Output> filterMapInputWithState<R, State>(
    State initial,
    (State, Optional<Input>) Function(State state, R input) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<R>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, R>>? internalBufferStrategy,
  }) {
    return MachineFactory.shared.feature<State, Output, Input, R, Output>(
      id: id,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
      onCreateFeature: () async {
        Outline<State, Output, Input, R, Output> outline(State state) {
          return Outline.create(
            state: state,
            transit: (state, trigger, id) {
              switch (trigger) {
                case InternalFeatureEvent(value: final value):
                  return OutlineTransition(
                    outline(state),
                    effects: IList([
                      ExternalFeatureEvent<Input, Output>(value),
                    ]),
                  );
                case ExternalFeatureEvent(value: final value):
                  final (newState, event) = function(state, value);

                  return OutlineTransition(
                    outline(newState),
                    effects: event.map((value) => [InternalFeatureEvent<Input, Output>(value)].lock).valueOr(const IList.empty()),
                  );
              }
            },
          );
        }

        return outline(initial).asFeature({this}.lock);
      },
      onDestroyFeature: (_) async {},
      shouldWaitOnEffects: shouldWaitOnEffects,
    );
  }

  Machine<R, Output> filterMapInput<R>(
    Optional<Input> Function(R input) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<R>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, R>>? internalBufferStrategy,
  }) {
    return filterMapInputWithState<R, ()>(
      (),
      (_, value) => ((), function(value)),
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }

  Machine<Input, R> filterMapOutputWithState<R, State>(
    State initial,
    (State, Optional<R>) Function(State state, Output output) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<R>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    return MachineFactory.shared.feature<State, Output, Input, Input, R>(
      id: id,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
      onCreateFeature: () async {
        Outline<State, Output, Input, Input, R> outline(State state) {
          return Outline.create(
            state: state,
            transit: (state, trigger, id) {
              switch (trigger) {
                case InternalFeatureEvent(value: final value):
                  final (newState, event) = function(state, value);
                  return OutlineTransition(
                    outline(newState),
                    effects: event.map((value) => [ExternalFeatureEvent<Input, R>(value)].lock).valueOr(const IList.empty()),
                  );
                case ExternalFeatureEvent(value: final value):
                  return OutlineTransition(
                    outline(state),
                    effects: [
                      InternalFeatureEvent<Input, R>(value),
                    ].lock,
                  );
              }
            },
          );
        }

        return outline(initial).asFeature({this}.lock);
      },
      onDestroyFeature: (_) async {},
      shouldWaitOnEffects: shouldWaitOnEffects,
    );
  }

  Machine<Input, R> filterMapOutput<R>(
    Optional<R> Function(Output output) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<R>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    return filterMapOutputWithState<R, ()>(
      (),
      (_, value) => ((), function(value)),
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}

extension FilterMapSiloExtension<T> on Silo<T> {
  Silo<R> filterMapWithState<R, State>(
    State initial,
    (State, Optional<R>) Function(State state, T value) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<R>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<T, Never>>? internalBufferStrategy,
  }) {
    return filterMapOutputWithState<R, State>(
      initial,
      function,
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: null,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }

  Silo<R> filterMap<R>(
    Optional<R> Function(T value) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<R>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<T, Never>>? internalBufferStrategy,
  }) {
    return filterMapOutput<R>(
      function,
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: null,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}

extension UnwrapInputMachineExtension<Input, Output> on Machine<Input, Output> {
  Machine<Optional<Input>, Output> unwrapInput({
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Optional<Input>>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Optional<Input>>>? internalBufferStrategy,
  }) {
    return filterMapInput(
      (value) => value,
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}

extension UnwrapOutputMachineExtension<Input, Output> on Machine<Input, Optional<Output>> {
  Machine<Input, Output> unwrapOutput({
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Optional<Output>, Input>>? internalBufferStrategy,
  }) {
    return filterMapOutput(
      (value) => value,
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}

extension UnwrapSiloExtension<Input, Output> on Silo<Optional<Output>> {
  Silo<Output> unwrap({
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Optional<Output>, Never>>? internalBufferStrategy,
  }) {
    return unwrapOutput(
      shouldWaitOnEffects: shouldWaitOnEffects,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}
