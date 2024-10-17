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

extension MapMachineExtension<Input, Output> on Machine<Input, Output> {
  Machine<R, Output> mapInputWithState<R, State>(
    State initial,
    (State, Input) Function(State state, R input) function, {
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
                    effects: [
                      ExternalFeatureEvent<Input, Output>(value),
                    ].lock,
                  );
                case ExternalFeatureEvent(value: final value):
                  final (newState, event) = function(state, value);

                  return OutlineTransition(
                    outline(newState),
                    effects: [
                      InternalFeatureEvent<Input, Output>(event),
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

  Machine<R, Output> mapInput<R>(
    Input Function(R input) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<R>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, R>>? internalBufferStrategy,
  }) {
    return mapInputWithState<R, ()>(
      (),
      (_, value) => ((), function(value)),
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }

  Machine<Input, R> mapOutputWithState<R, State>(
    State initial,
    (State, R) Function(State state, Output output) function, {
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
                    effects: [
                      ExternalFeatureEvent<Input, R>(event),
                    ].lock,
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

  Machine<Input, R> mapOutput<R>(
    R Function(Output output) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<R>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    return mapOutputWithState<R, ()>(
      (),
      (_, value) => ((), function(value)),
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}

extension MapSiloExtension<T> on Silo<T> {
  Silo<R> mapWithState<R, State>(
    State initial,
    (State, R) Function(State state, T value) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<R>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<T, Never>>? internalBufferStrategy,
  }) {
    return mapOutputWithState<R, State>(
      initial,
      function,
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: null,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }

  Silo<R> map<R>(
    R Function(T value) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<R>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<T, Never>>? internalBufferStrategy,
  }) {
    return mapOutput<R>(
      function,
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: null,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}
