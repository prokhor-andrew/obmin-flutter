// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/machine_ext/feature_machine/feature.dart';
import 'package:obmin/machine_ext/feature_machine/outline.dart';

final class Scene<State, Trigger, Effect> {
  final State state;
  final SceneTransition<State, Trigger, Effect> Function(
    Trigger,
    String,
  ) transit;

  const Scene._({
    required this.state,
    required this.transit,
  });

  static Scene<State, Trigger, Effect> create<State, Trigger, Effect>({
    required State state,
    required SceneTransition<State, Trigger, Effect> Function(
      State state,
      Trigger trigger,
      String machineId,
    ) transit,
  }) {
    return Scene._(
      state: state,
      transit: (trigger, machineId) {
        return transit(
          state,
          trigger,
          machineId,
        );
      },
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Scene<State, Trigger, Effect> && runtimeType == other.runtimeType && state == other.state;
  }

  @override
  int get hashCode => state.hashCode;

  @override
  String toString() {
    return "Scene<$State, $Trigger, $Effect>{ state=$state }";
  }
}

final class SceneTransition<State, Trigger, Effect> {
  final Scene<State, Trigger, Effect> scene;
  final List<Effect> effects;

  const SceneTransition(
    this.scene, {
    this.effects = const [],
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SceneTransition<State, Trigger, Effect> && runtimeType == other.runtimeType && scene == other.scene && effects == other.effects;
  }

  @override
  int get hashCode => scene.hashCode ^ effects.hashCode;

  @override
  String toString() {
    return "SceneTransition<$State, $Trigger, $Effect>{ scene=$scene _ effects=$effects }";
  }
}

extension SceneToOutlineConverter<State, Trigger, Effect> on Scene<State, Trigger, Effect> {
  Outline<State, IntTrigger, IntEffect, Trigger, Effect> asExtTriggerExtEffect<IntTrigger, IntEffect>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent():
            return OutlineTransition(asExtTriggerExtEffect());
          case ExternalFeatureEvent(value: final value):
            final transition = transit(value, machineId);
            return OutlineTransition(
              transition.scene.asExtTriggerExtEffect(),
              effects: transition.effects.map(
                (effect) {
                  return ExternalFeatureEvent<IntEffect, Effect>(effect);
                },
              ).toList(),
            );
        }
      },
    );
  }

  Outline<State, IntTrigger, Effect, Trigger, ExtEffect> asIntEffectExtTrigger<IntTrigger, ExtEffect>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent():
            return OutlineTransition(asIntEffectExtTrigger());
          case ExternalFeatureEvent(value: final value):
            final transition = transit(value, machineId);
            return OutlineTransition(
              transition.scene.asIntEffectExtTrigger(),
              effects: transition.effects.map(
                (effect) {
                  return InternalFeatureEvent<Effect, ExtEffect>(effect);
                },
              ).toList(),
            );
        }
      },
    );
  }

  Outline<State, Trigger, IntEffect, ExtTrigger, Effect> asIntTriggerExtEffect<IntEffect, ExtTrigger>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value):
            final transition = transit(value, machineId);
            return OutlineTransition(
              transition.scene.asIntTriggerExtEffect(),
              effects: transition.effects.map(
                (effect) {
                  return ExternalFeatureEvent<IntEffect, Effect>(effect);
                },
              ).toList(),
            );
          case ExternalFeatureEvent():
            return OutlineTransition(asIntTriggerExtEffect());
        }
      },
    );
  }

  Outline<State, Trigger, Effect, ExtTrigger, ExtEffect> asIntTriggerIntEffect<ExtTrigger, ExtEffect>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value):
            final transition = transit(value, machineId);
            return OutlineTransition(
              transition.scene.asIntTriggerIntEffect(),
              effects: transition.effects.map(
                (effect) {
                  return InternalFeatureEvent<Effect, ExtEffect>(effect);
                },
              ).toList(),
            );
          case ExternalFeatureEvent():
            return OutlineTransition(asIntTriggerIntEffect());
        }
      },
    );
  }

  Outline<State, IntTrigger, Effect, Trigger, Effect> asIntEffectExtTriggerExtEffect<IntTrigger>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent():
            return OutlineTransition(asIntEffectExtTriggerExtEffect());
          case ExternalFeatureEvent(value: final value):
            final transition = transit(value, machineId);
            return OutlineTransition(
              transition.scene.asIntEffectExtTriggerExtEffect(),
              effects: transition.effects.expand(
                (effect) {
                  return [
                    InternalFeatureEvent<Effect, Effect>(effect),
                    ExternalFeatureEvent<Effect, Effect>(effect),
                  ];
                },
              ).toList(),
            );
        }
      },
    );
  }

  Outline<State, Trigger, Effect, ExtTrigger, Effect> asIntTriggerIntEffectExtEffect<ExtTrigger>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value):
            final transition = transit(value, machineId);
            return OutlineTransition(
              transition.scene.asIntTriggerIntEffectExtEffect(),
              effects: transition.effects.expand(
                (effect) {
                  return [
                    InternalFeatureEvent<Effect, Effect>(effect),
                    ExternalFeatureEvent<Effect, Effect>(effect),
                  ];
                },
              ).toList(),
            );
          case ExternalFeatureEvent():
            return OutlineTransition(asIntTriggerIntEffectExtEffect());
        }
      },
    );
  }

  Outline<State, Trigger, Effect, Trigger, ExtEffect> asIntTriggerIntEffectExtTrigger<ExtEffect>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value) || ExternalFeatureEvent(value: final value):
            final transition = transit(value, machineId);
            return OutlineTransition(
              transition.scene.asIntTriggerIntEffectExtTrigger(),
              effects: transition.effects.map(
                (effect) {
                  return InternalFeatureEvent<Effect, ExtEffect>(effect);
                },
              ).toList(),
            );
        }
      },
    );
  }

  Outline<State, Trigger, IntEffect, Trigger, Effect> asIntTriggerExtTriggerExtEffect<IntEffect>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value) || ExternalFeatureEvent(value: final value):
            final transition = transit(value, machineId);
            return OutlineTransition(
              transition.scene.asIntTriggerExtTriggerExtEffect(),
              effects: transition.effects.map(
                (effect) {
                  return ExternalFeatureEvent<IntEffect, Effect>(effect);
                },
              ).toList(),
            );
        }
      },
    );
  }

  Outline<State, Trigger, Effect, Trigger, Effect> asIntTriggerIntEffectExtTriggerExtEffect() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value) || ExternalFeatureEvent(value: final value):
            final transition = transit(value, machineId);
            return OutlineTransition(
              transition.scene.asIntTriggerIntEffectExtTriggerExtEffect(),
              effects: transition.effects.expand(
                (effect) {
                  return [
                    InternalFeatureEvent<Effect, Effect>(effect),
                    ExternalFeatureEvent<Effect, Effect>(effect),
                  ];
                },
              ).toList(),
            );
        }
      },
    );
  }
}
