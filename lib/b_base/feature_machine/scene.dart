// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin_concept/a_foundation/types/writer.dart';
import 'package:obmin_concept/b_base/feature_machine/feature.dart';
import 'package:obmin_concept/b_base/feature_machine/outline.dart';

final class Scene<State, Trigger, Effect, Loggable> {
  final State state;
  final Writer<SceneTransition<State, Trigger, Effect, Loggable>, Loggable> Function(
    Trigger,
    String,
  ) transit;

  Scene._({
    required this.state,
    required this.transit,
  });

  static Scene<State, Trigger, Effect, Loggable> create<State, Trigger, Effect, Loggable>({
    required State state,
    required Writer<SceneTransition<State, Trigger, Effect, Loggable>, Loggable> Function(
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
    return identical(this, other) || other is Scene<State, Trigger, Effect, Loggable> && runtimeType == other.runtimeType && state == other.state;
  }

  @override
  int get hashCode => state.hashCode;

  @override
  String toString() {
    return "Scene<$State, $Trigger, $Effect, $Loggable>{ state=$state }";
  }
}

final class SceneTransition<State, Trigger, Effect, Loggable> {
  final Scene<State, Trigger, Effect, Loggable> scene;
  final List<Effect> effects;

  SceneTransition(
    this.scene, {
    this.effects = const [],
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SceneTransition<State, Trigger, Effect, Loggable> && runtimeType == other.runtimeType && scene == other.scene && effects == other.effects;
  }

  @override
  int get hashCode => scene.hashCode ^ effects.hashCode;
}

extension SceneToOutlineConverter<State, Trigger, Effect, Loggable> on Scene<State, Trigger, Effect, Loggable> {
  Outline<State, IntTrigger, IntEffect, Trigger, Effect, Loggable> asExtTriggerExtEffect<IntTrigger, IntEffect>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent():
            return Writer(OutlineTransition(asExtTriggerExtEffect()));
          case ExternalFeatureEvent(value: final value):
            return transit(value, machineId).map(
              (transition) {
                return OutlineTransition(transition.scene.asExtTriggerExtEffect(),
                    effects: transition.effects.map(
                      (effect) {
                        return ExternalFeatureEvent<IntEffect, Effect>(effect);
                      },
                    ).toList());
              },
            );
        }
      },
    );
  }

  Outline<State, IntTrigger, Effect, Trigger, ExtEffect, Loggable> asIntEffectExtTrigger<IntTrigger, ExtEffect>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent():
            return Writer(OutlineTransition(asIntEffectExtTrigger()));
          case ExternalFeatureEvent(value: final value):
            return transit(value, machineId).map(
              (transition) {
                return OutlineTransition(
                  transition.scene.asIntEffectExtTrigger(),
                  effects: transition.effects.map(
                    (effect) {
                      return InternalFeatureEvent<Effect, ExtEffect>(effect);
                    },
                  ).toList(),
                );
              },
            );
        }
      },
    );
  }

  Outline<State, Trigger, IntEffect, ExtTrigger, Effect, Loggable> asIntTriggerExtEffect<IntEffect, ExtTrigger>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value):
            return transit(value, machineId).map(
              (transition) {
                return OutlineTransition(
                  transition.scene.asIntTriggerExtEffect(),
                  effects: transition.effects.map(
                    (effect) {
                      return ExternalFeatureEvent<IntEffect, Effect>(effect);
                    },
                  ).toList(),
                );
              },
            );
          case ExternalFeatureEvent():
            return Writer(OutlineTransition(asIntTriggerExtEffect()));
        }
      },
    );
  }

  Outline<State, Trigger, Effect, ExtTrigger, ExtEffect, Loggable> asIntTriggerIntEffect<ExtTrigger, ExtEffect>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value):
            return transit(value, machineId).map(
              (transition) {
                return OutlineTransition(
                  transition.scene.asIntTriggerIntEffect(),
                  effects: transition.effects.map(
                    (effect) {
                      return InternalFeatureEvent<Effect, ExtEffect>(effect);
                    },
                  ).toList(),
                );
              },
            );
          case ExternalFeatureEvent():
            return Writer(OutlineTransition(asIntTriggerIntEffect()));
        }
      },
    );
  }

  Outline<State, IntTrigger, Effect, Trigger, Effect, Loggable> asIntEffectExtTriggerExtEffect<IntTrigger>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent():
            return Writer(
              OutlineTransition(asIntEffectExtTriggerExtEffect()),
            );
          case ExternalFeatureEvent(value: final value):
            return transit(value, machineId).map(
              (transition) {
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
              },
            );
        }
      },
    );
  }

  Outline<State, Trigger, Effect, ExtTrigger, Effect, Loggable> asIntTriggerIntEffectExtEffect<ExtTrigger>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value):
            return transit(value, machineId).map(
              (transition) {
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
              },
            );
          case ExternalFeatureEvent():
            return Writer(OutlineTransition(asIntTriggerIntEffectExtEffect()));
        }
      },
    );
  }

  Outline<State, Trigger, Effect, Trigger, ExtEffect, Loggable> asIntTriggerIntEffectExtTrigger<ExtEffect>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value) || ExternalFeatureEvent(value: final value):
            return transit(value, machineId).map(
              (transition) {
                return OutlineTransition(
                  transition.scene.asIntTriggerIntEffectExtTrigger(),
                  effects: transition.effects.map(
                    (effect) {
                      return InternalFeatureEvent<Effect, ExtEffect>(effect);
                    },
                  ).toList(),
                );
              },
            );
        }
      },
    );
  }

  Outline<State, Trigger, IntEffect, Trigger, Effect, Loggable> asIntTriggerExtTriggerExtEffect<IntEffect>() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value) || ExternalFeatureEvent(value: final value):
            return transit(value, machineId).map(
              (transition) {
                return OutlineTransition(
                  transition.scene.asIntTriggerExtTriggerExtEffect(),
                  effects: transition.effects.map(
                    (effect) {
                      return ExternalFeatureEvent<IntEffect, Effect>(effect);
                    },
                  ).toList(),
                );
              },
            );
        }
      },
    );
  }

  Outline<State, Trigger, Effect, Trigger, Effect, Loggable> asIntTriggerIntEffectExtTriggerExtEffect() {
    return Outline.create(
      state: state,
      transit: (state, trigger, machineId) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value) || ExternalFeatureEvent(value: final value):
            return transit(value, machineId).map(
              (transition) {
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
              },
            );
        }
      },
    );
  }
}
