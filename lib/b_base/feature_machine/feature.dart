import 'package:obmin_concept/a_foundation/machine.dart';

final class Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> {
  final State state;
  final Set<Machine<IntEffect, IntTrigger, Loggable>> machines;
  final FeatureTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> Function(
    FeatureEvent<IntTrigger, ExtTrigger> event,
    String machineId,
  ) transit;

  Feature._({
    required this.state,
    required this.machines,
    required this.transit,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> &&
            runtimeType == other.runtimeType &&
            state == other.state &&
            machines == other.machines;
  }

  @override
  int get hashCode => state.hashCode ^ machines.hashCode;

  static Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> create<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable>({
    required State state,
    required Set<Machine<IntEffect, IntTrigger, Loggable>> machines,
    required FeatureTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> Function(
      State state,
      Set<Machine<IntEffect, IntTrigger, Loggable>> machines,
      FeatureEvent<IntTrigger, ExtTrigger> trigger,
      String machineId,
    ) transit,
  }) {
    return Feature._(
      state: state,
      machines: machines,
      transit: (trigger, machineId) {
        return transit(
          state,
          machines,
          trigger,
          machineId,
        );
      },
    );
  }
}

final class FeatureTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> {
  final Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> feature;
  final List<FeatureEvent<IntEffect, ExtEffect>> effects;
  final List<Loggable> logs;

  FeatureTransition(
    this.feature, {
    this.effects = const [],
    this.logs = const [],
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FeatureTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> &&
            runtimeType == other.runtimeType &&
            feature == other.feature &&
            effects == other.effects &&
            logs == other.logs;
  }

  @override
  int get hashCode => feature.hashCode ^ effects.hashCode ^ logs.hashCode;
}

sealed class FeatureEvent<Int, Ext> {
  bool get isExternal => switch (this) {
        InternalFeatureEvent<Int, Ext>() => false,
        ExternalFeatureEvent<Int, Ext>() => true,
      };

  bool get isInternal => !isExternal;
}

final class InternalFeatureEvent<Int, Ext> extends FeatureEvent<Int, Ext> {
  final Int value;

  InternalFeatureEvent(this.value);

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is InternalFeatureEvent<Int, Ext> && runtimeType == other.runtimeType && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

final class ExternalFeatureEvent<Int, Ext> extends FeatureEvent<Int, Ext> {
  final Ext value;

  ExternalFeatureEvent(this.value);

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is ExternalFeatureEvent<Int, Ext> && runtimeType == other.runtimeType && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}
