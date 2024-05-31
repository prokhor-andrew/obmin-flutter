import 'package:obmin_concept/a_foundation/machine.dart';
import 'package:obmin_concept/a_foundation/types/writer.dart';
import 'package:obmin_concept/b_base/feature_machine/feature.dart';

final class Outline<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> {
  final State state;
  final Writer<OutlineTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable>, Loggable> Function(
    FeatureEvent<IntTrigger, ExtTrigger>,
    String,
  ) transit;

  Outline._({
    required this.state,
    required this.transit,
  });

  static Outline<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> create<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable>({
    required State state,
    required Writer<OutlineTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable>, Loggable> Function(
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
  String toString() {
    return "Outline<$State, $IntTrigger, $IntEffect, $ExtTrigger, $ExtEffect, $Loggable>{ state=$state }";
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
        return transit(trigger, machineId).map((transition) {
          return FeatureTransition(
            transition.outline.asFeature(machines),
            effects: transition.effects,
          );
        });
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
