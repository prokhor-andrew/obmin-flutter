import 'package:obmin_concept/b_base/feature_machine/feature.dart';
import 'package:obmin_concept/a_foundation/machine.dart';
import 'package:obmin_concept/a_foundation/machine_logger.dart';

final class Outline<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> {
  final State state;
  final OutlineTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> Function(
    FeatureEvent<IntTrigger, ExtTrigger>,
    String,
    MachineLogger<Loggable>,
  ) transit;

  Outline._({
    required this.state,
    required this.transit,
  });

  static Outline<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> create<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable>({
    required State state,
    required OutlineTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> Function(
      OutlineExtras<State, Loggable> extras,
      FeatureEvent<IntTrigger, ExtTrigger> trigger,
    ) transit,
  }) {
    return Outline._(
      state: state,
      transit: (trigger, machineId, logger) {
        return transit(
          OutlineExtras._(
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
    return identical(this, other) ||
        other is Outline<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> && runtimeType == other.runtimeType && state == other.state;
  }

  @override
  int get hashCode => state.hashCode;

  OutlineExtras<State, Loggable> extras({
    required String machineId,
    required MachineLogger<Loggable> logger,
  }) {
    return OutlineExtras._(
      state: state,
      machineId: machineId,
      logger: logger,
    );
  }

  Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> asFeature(Set<Machine<IntEffect, IntTrigger, Loggable>> machines) {
    return Feature.create(
      state: state,
      machines: machines,
      transit: (extras, trigger) {
        final transition = transit(trigger, extras.machineId, extras.logger);
        return FeatureTransition(
          transition.outline.asFeature(machines),
          effects: transition.effects,
        );
      },
    );
  }
}

final class OutlineTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> {
  final Outline<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> outline;
  final List<FeatureEvent<IntEffect, ExtEffect>> effects;

  OutlineTransition(
    this.outline, {
    this.effects = const [],
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OutlineTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> &&
            runtimeType == other.runtimeType &&
            outline == other.outline &&
            effects == other.effects;
  }

  @override
  int get hashCode => outline.hashCode ^ effects.hashCode;
}

final class OutlineExtras<State, Loggable> {
  final State state;
  final String machineId;
  final MachineLogger<Loggable> logger;

  OutlineExtras._({
    required this.state,
    required this.machineId,
    required this.logger,
  });
}
