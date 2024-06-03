// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/machine.dart';
import 'package:obmin/a_foundation/machine_logger.dart';
import 'package:obmin/a_foundation/types/writer.dart';
import 'package:obmin/b_base/feature_machine/scene.dart';
import 'package:obmin/c_core/core.dart';

Core<State, State, Event, Loggable> CoreX<State, Event, Loggable>({
  required State Function() state,
  required Writer<State, Loggable> Function(State state, Event event) reducer,
  required Set<Machine<State, Event, Loggable>> Function(State state) machines,
  required Set<MachineLogger<Loggable>> Function() loggers,
}) {
  return Core(
    scene: () {
      Scene<State, Event, State, Loggable> scene(State state) {
        return Scene.create(
          state: state,
          transit: (state, trigger, machineId) {
            return reducer(state, trigger).map((value) {
              return SceneTransition(
                scene(value),
                effects: [value],
              );
            });
          },
        );
      }

      return scene(state());
    },
    machines: machines,
    loggers: loggers,
  );
}
