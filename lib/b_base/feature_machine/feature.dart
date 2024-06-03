// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:collection/collection.dart';
import 'package:obmin/a_foundation/machine.dart';
import 'package:obmin/a_foundation/types/writer.dart';

final class Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> {
  final State state;
  final Set<Machine<IntEffect, IntTrigger, Loggable>> machines;

  final Writer<FeatureTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable>, Loggable> Function(
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
    if (identical(this, other)) return true;

    return other is Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> &&
        other.state == state &&
        const SetEquality().equals(other.machines, machines);
  }

  @override
  int get hashCode => Object.hash(
        state,
        const SetEquality().hash(machines),
      );

  @override
  String toString() {
    return "Feature<$State, $IntTrigger, $IntEffect, $ExtTrigger, $ExtEffect, $Loggable>{ state=$state _ machines=$machines }";
  }

  static Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> create<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable>({
    required State state,
    required Set<Machine<IntEffect, IntTrigger, Loggable>> machines,
    required Writer<FeatureTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable>, Loggable> Function(
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

  FeatureTransition(
    this.feature, {
    this.effects = const [],
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FeatureTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect, Loggable> &&
        other.feature == feature &&
        const ListEquality().equals(other.effects, effects);
  }

  @override
  int get hashCode => feature.hashCode ^ const ListEquality().hash(effects);

  @override
  String toString() {
    return "FeatureTransition<$State, $IntTrigger, $IntEffect, $ExtTrigger, $ExtEffect, $Loggable>{ feature=$feature _ effects=$effects }";
  }
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

  @override
  String toString() {
    return "InternalFeatureEvent<$Int, $Ext> { value=$value }";
  }
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

  @override
  String toString() {
    return "ExternalFeatureEvent<$Int, $Ext> { value=$value }";
  }
}
