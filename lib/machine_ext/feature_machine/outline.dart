// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine_ext/feature_machine/feature.dart';

final class Outline<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect> {
  final State state;
  final OutlineTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect> Function(
    FeatureEvent<IntTrigger, ExtTrigger>,
    String,
  ) transit;

  const Outline._({
    required this.state,
    required this.transit,
  });

  static Outline<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect> create<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect>({
    required State state,
    required OutlineTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect> Function(
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
    return "Outline<$State, $IntTrigger, $IntEffect, $ExtTrigger, $ExtEffect>{ state=$state }";
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Outline<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect> && runtimeType == other.runtimeType && state == other.state;
  }

  @override
  int get hashCode => state.hashCode;

  Feature<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect> asFeature(ISet<Machine<IntEffect, IntTrigger>> machines) {
    return Feature.create(
      state: state,
      machines: machines,
      transit: (state, machines, trigger, machineId) {
        final transition = transit(trigger, machineId);
        return FeatureTransition(
          transition.outline.asFeature(machines),
          effects: transition.effects,
        );
      },
    );
  }
}

final class OutlineTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect> {
  final Outline<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect> outline;
  final IList<FeatureEvent<IntEffect, ExtEffect>> effects;

  const OutlineTransition(
    this.outline, {
    this.effects = const IList.empty(),
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OutlineTransition<State, IntTrigger, IntEffect, ExtTrigger, ExtEffect> &&
            runtimeType == other.runtimeType &&
            outline == other.outline &&
            effects == other.effects;
  }

  @override
  int get hashCode => outline.hashCode ^ effects.hashCode;

  @override
  String toString() {
    return "OutlineTransition<$State, $IntTrigger, $IntEffect, $ExtTrigger, $ExtEffect>{ outline=$outline _ effects=$effects }";
  }
}
