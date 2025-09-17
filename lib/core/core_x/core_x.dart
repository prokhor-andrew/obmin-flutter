// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/core/core.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine/plan.dart';
import 'package:obmin/types/either.dart';

Core<State, State, Event> CoreX<State, Event>({
  required State Function() state,
  required State Function(State state, Event event) reducer,
  required IMap<String, Machine<State, Event>> Function(State state) machines,
}) {
  return Core(
    plan: () {
      Plan<State, Event, State, Never, Never> scene(State state) {
        return Plan.create(
          state: state,
          transit: (state, trigger) {
            final value = reducer(state, trigger.value());
            return PlanTransition(
              scene(value),
              effects: [Either.left<State, Never>(value)].lock,
            );
          },
        );
      }

      return scene(state());
    },
    machines: machines,
  );
}
