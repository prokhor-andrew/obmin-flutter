import 'package:obmin_concept/a_foundation/machine.dart';
import 'package:obmin_concept/b_base/feature_machine/feature.dart';

final class Outline<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> {
  final State state;
  final OutlineTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> Function(
    FeatureEvent<IntTrigger, ExtTrigger>,
    String,
  ) transit;

  Outline._({
    required this.state,
    required this.transit,
  });

  static Outline<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> create<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable>({
    required State state,
    required OutlineTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> Function(
      State state,
      FeatureEvent<IntTrigger, ExtTrigger> trigger,
      String machineId,
    ) transit,
  }) {
    return Outline._(
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
    return identical(this, other) ||
        other is Outline<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> && runtimeType == other.runtimeType && state == other.state;
  }

  @override
  int get hashCode => state.hashCode;

  Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> asFeature(Set<Machine<IntEffect, IntTrigger, Loggable>> machines) {
    return Feature.create(
      state: state,
      machines: machines,
      transit: (state, machines, trigger, machineId) {
        final transition = transit(trigger, machineId);
        return FeatureTransition(
          transition.outline.asFeature(machines),
          effects: transition.effects,
          logs: transition.logs,
        );
      },
    );
  }
}

final class OutlineTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> {
  final Outline<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> outline;
  final List<FeatureEvent<IntEffect, ExtEffect>> effects;
  final List<Loggable> logs;

  OutlineTransition(
    this.outline, {
    this.effects = const [],
    this.logs = const [],
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OutlineTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> &&
            runtimeType == other.runtimeType &&
            outline == other.outline &&
            effects == other.effects &&
            logs == other.logs;
  }

  @override
  int get hashCode => outline.hashCode ^ effects.hashCode ^ logs.hashCode;
}
