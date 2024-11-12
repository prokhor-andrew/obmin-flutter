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

extension FilterMachineExtension<Input, Output> on Machine<Input, Output> {
  Machine<Input, Output> filterInputWithState<State>(
    State initial,
    (State, bool) Function(State state, Input input) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    return MachineFactory.shared.feature<State, Output, Input, Input, Output>(
      id: id,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
      onCreateFeature: () async {
        Outline<State, Output, Input, Input, Output> outline(State state) {
          return Outline.create(
            state: state,
            transit: (state, trigger, id) {
              switch (trigger) {
                case InternalFeatureEvent(value: final value):
                  return OutlineTransition(
                    outline(state),
                    effects: [
                      ExternalFeatureEvent<Input, Output>(value),
                    ],
                  );
                case ExternalFeatureEvent(value: final value):
                  final (newState, event) = function(state, value);

                  return OutlineTransition(
                    outline(newState),
                    effects: event
                        ? [
                            InternalFeatureEvent<Input, Output>(value),
                          ]
                        : [],
                  );
              }
            },
          );
        }

        return outline(initial).asFeature({this});
      },
      onDestroyFeature: (_) async {},
      shouldWaitOnEffects: shouldWaitOnEffects,
    );
  }

  Machine<Input, Output> filterInput(
    bool Function(Input input) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    return filterInputWithState<()>(
      (),
      (_, value) => ((), function(value)),
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }

  Machine<Input, Output> filterOutputWithState<State>(
    State initial,
    (State, bool) Function(State state, Output output) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    return MachineFactory.shared.feature<State, Output, Input, Input, Output>(
      id: id,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
      onCreateFeature: () async {
        Outline<State, Output, Input, Input, Output> outline(State state) {
          return Outline.create(
            state: state,
            transit: (state, trigger, id) {
              switch (trigger) {
                case InternalFeatureEvent(value: final value):
                  final (newState, event) = function(state, value);
                  return OutlineTransition(
                    outline(newState),
                    effects: event
                        ? [
                            ExternalFeatureEvent<Input, Output>(value),
                          ]
                        : [],
                  );
                case ExternalFeatureEvent(value: final value):
                  return OutlineTransition(
                    outline(state),
                    effects: [
                      InternalFeatureEvent<Input, Output>(value),
                    ],
                  );
              }
            },
          );
        }

        return outline(initial).asFeature({this});
      },
      onDestroyFeature: (_) async {},
      shouldWaitOnEffects: shouldWaitOnEffects,
    );
  }

  Machine<Input, Output> filterOutput(
    bool Function(Output output) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    return filterOutputWithState<()>(
      (),
      (_, value) => ((), function(value)),
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}

extension FilterSiloExtension<T> on Silo<T> {
  Silo<T> filterWithState<State>(
    State initial,
    (State, bool) Function(State state, T value) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<T>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<T, Never>>? internalBufferStrategy,
  }) {
    return filterOutputWithState<State>(
      initial,
      function,
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: null,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }

  Silo<T> filter(
    bool Function(T value) function, {
    bool shouldWaitOnEffects = false,
    ChannelBufferStrategy<T>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<T, Never>>? internalBufferStrategy,
  }) {
    return filterOutput(
      function,
      shouldWaitOnEffects: shouldWaitOnEffects,
      inputBufferStrategy: null,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}
