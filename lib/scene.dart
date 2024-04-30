import 'package:obmin_concept/feature.dart';
import 'package:obmin_concept/machine_logger.dart';
import 'package:obmin_concept/outline.dart';

final class Scene<State, Trigger, Effect, Loggable> {
  final State state;
  final SceneTransition<State, Trigger, Effect, Loggable> Function(
    Trigger,
    String,
    MachineLogger<Loggable>,
  ) transit;

  Scene._({
    required this.state,
    required this.transit,
  });

  static Scene<State, Trigger, Effect, Loggable> create<State, Trigger, Effect, Loggable>({
    required State state,
    required SceneTransition<State, Trigger, Effect, Loggable> Function(SceneExtras<State, Loggable> extras, Trigger trigger) transit,
  }) {
    return Scene._(
      state: state,
      transit: (trigger, machineId, logger) {
        return transit(
          SceneExtras._(
            state: state,
            machineId: machineId,
            logger: logger,
          ),
          trigger,
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

  SceneExtras<State, Loggable> extras({
    required String machineId,
    required MachineLogger<Loggable> logger,
  }) {
    return SceneExtras._(
      state: state,
      machineId: machineId,
      logger: logger,
    );
  }
}

final class SceneExtras<State, Loggable> {
  final State state;
  final String machineId;
  final MachineLogger<Loggable> logger;

  SceneExtras._({
    required this.state,
    required this.machineId,
    required this.logger,
  });
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
      transit: (extras, trigger) {
        switch (trigger) {
          case InternalFeatureEvent():
            return OutlineTransition(asExtTriggerExtEffect());
          case ExternalFeatureEvent(value: final value):
            final transition = transit(value, extras.machineId, extras.logger);
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

  Outline<State, IntTrigger, Effect, Trigger, ExtEffect, Loggable> asIntEffectExtTrigger<IntTrigger, ExtEffect>() {
    return Outline.create(
      state: state,
      transit: (extras, trigger) {
        switch (trigger) {
          case InternalFeatureEvent():
            return OutlineTransition(asIntEffectExtTrigger());
          case ExternalFeatureEvent(value: final value):
            final transition = transit(value, extras.machineId, extras.logger);
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

  Outline<State, Trigger, IntEffect, ExtTrigger, Effect, Loggable> asIntTriggerExtEffect<IntEffect, ExtTrigger>() {
    return Outline.create(
      state: state,
      transit: (extras, trigger) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value):
            final transition = transit(value, extras.machineId, extras.logger);
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

  Outline<State, Trigger, Effect, ExtTrigger, ExtEffect, Loggable> asIntTriggerIntEffect<ExtTrigger, ExtEffect>() {
    return Outline.create(
      state: state,
      transit: (extras, trigger) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value):
            final transition = transit(value, extras.machineId, extras.logger);
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

  Outline<State, IntTrigger, Effect, Trigger, Effect, Loggable> asIntEffectExtTriggerExtEffect<IntTrigger>() {
    return Outline.create(
      state: state,
      transit: (extras, trigger) {
        switch (trigger) {
          case InternalFeatureEvent():
            return OutlineTransition(asIntEffectExtTriggerExtEffect());
          case ExternalFeatureEvent(value: final value):
            final transition = transit(value, extras.machineId, extras.logger);
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

  Outline<State, Trigger, Effect, ExtTrigger, Effect, Loggable> asIntTriggerIntEffectExtEffect<ExtTrigger>() {
    return Outline.create(
      state: state,
      transit: (extras, trigger) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value):
            final transition = transit(value, extras.machineId, extras.logger);
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

  Outline<State, Trigger, Effect, Trigger, ExtEffect, Loggable> asIntTriggerIntEffectExtTrigger<ExtEffect>() {
    return Outline.create(
      state: state,
      transit: (extras, trigger) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value) || ExternalFeatureEvent(value: final value):
            final transition = transit(value, extras.machineId, extras.logger);
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

  Outline<State, Trigger, IntEffect, Trigger, Effect, Loggable> asIntTriggerExtTriggerExtEffect<IntEffect>() {
    return Outline.create(
      state: state,
      transit: (extras, trigger) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value) || ExternalFeatureEvent(value: final value):
            final transition = transit(value, extras.machineId, extras.logger);
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

  Outline<State, Trigger, Effect, Trigger, Effect, Loggable> asIntTriggerIntEffectExtTriggerExtEffect() {
    return Outline.create(
      state: state,
      transit: (extras, trigger) {
        switch (trigger) {
          case InternalFeatureEvent(value: final value) || ExternalFeatureEvent(value: final value):
            final transition = transit(value, extras.machineId, extras.logger);

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
