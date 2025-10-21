// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart' hide Output;
import 'package:obmin/obmin.dart';

final class Core<S, Input, Output> {
  final Plan<S, Output, Input, Never, Never> Function() plan;
  final IMap<String, Machine<Input, Output>> Function(S state) machines;

  Process? _process;

  Core({
    required this.plan,
    required this.machines,
  });

  bool get isStarted => _process != null;

  bool start() {
    if (_process != null) {
      return false;
    }

    _process = Machine.fromMealy(
      onCreateMealy: () async {
        final aPlan = plan();
        final aMachines = machines(aPlan.state);
        return aPlan.asMealy(aMachines);
      },
      onDestroyMealy: (_) async {},
      shouldWaitOnEffects: false,
    ).run(
      onChange: (_) async {},
      onConsume: (_) async {},
    );

    return true;
  }

  bool stop() {
    if (_process == null) {
      return false;
    }

    _process?.cancel();
    _process = null;

    return true;
  }

  static Core<S, S, Event> createX<S, Event>({
    required S Function() state,
    required S Function(S state, Event event) reducer,
    required IMap<String, Machine<S, Event>> Function(S state) machines,
  }) {
    return Core(
      plan: () {
        Plan<S, Event, S, Never, Never> scene(S state) {
          return Plan.create(
            state: state,
            transit: (state, trigger) {
              final value = reducer(state, trigger.value());
              return PlanTransition(
                scene(value),
                effects: [Either.left<S, Never>(value)].lock,
              );
            },
          );
        }

        return scene(state());
      },
      machines: machines,
    );
  }

  static Core<S, S, Endo<S>> createY<S>({
    required S Function() state,
    required IMap<String, Machine<S, Endo<S>>> Function(S state) machines,
  }) {
    return createX(
      state: state,
      reducer: (state, reducer) {
        return reducer(state);
      },
      machines: machines,
    );
  }
}
