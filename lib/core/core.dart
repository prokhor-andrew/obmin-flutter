// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine/plan.dart';

final class Core<State, Input, Output> {
  final Plan<State, Output, Input, Never, Never> Function() plan;
  final IMap<String, Machine<Input, Output>> Function(State state) machines;

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
}
