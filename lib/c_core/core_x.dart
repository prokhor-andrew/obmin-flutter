// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/machine.dart';
import 'package:obmin/b_base/feature_machine/scene.dart';
import 'package:obmin/c_core/core.dart';

Core<State, State, Event> CoreX<State, Event>({
  required State Function() state,
  required State Function(State state, Event event) reducer,
  required Set<Machine<State, Event>> Function(State state) machines,
}) {
  return Core(
    scene: () {
      Scene<State, Event, State> scene(State state) {
        return Scene.create(
          state: state,
          transit: (state, trigger, machineId) {
            final value = reducer(state, trigger);
            return SceneTransition(
              scene(value),
              effects: [value],
            );
          },
        );
      }

      return scene(state());
    },
    machines: machines,
  );
}
