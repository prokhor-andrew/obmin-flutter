// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/core/core.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine_ext/feature_machine/scene.dart';

Core<State, State, Event> CoreX<State, Event>({
  required State Function(CoreInitialObject initial) state,
  required State Function(State state, Event event) reducer,
  required ISet<Machine<State, Event>> Function(State state) machines,
}) {
  return Core(
    scene: (initial) {
      Scene<State, Event, State> scene(State state) {
        return Scene.create(
          state: state,
          transit: (state, trigger, machineId) {
            final value = reducer(state, trigger);
            return SceneTransition(
              scene(value),
              effects: [value].lock,
            );
          },
        );
      }

      return scene(state(initial));
    },
    machines: machines,
  );
}
