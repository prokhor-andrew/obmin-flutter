// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/machine.dart';
import 'package:obmin/a_foundation/machine_factory.dart';
import 'package:obmin/b_base/feature_machine/feature_machine.dart';
import 'package:obmin/b_base/feature_machine/scene.dart';

final class Core<State, Input, Output> {
  final Scene<State, Output, Input> Function() scene;
  final Set<Machine<Input, Output>> Function(State state) machines;

  Process<void>? _process;

  Core({
    required this.scene,
    required this.machines,
  });

  bool get isStarted => _process != null;

  bool start() {
    if (_process != null) {
      return false;
    }

    _process = MachineFactory.shared
        .feature(
          id: "core",
          onCreateFeature: () async {
            final aScene = scene();
            final aMachines = machines(aScene.state);
            return aScene.asIntTriggerIntEffect<void, void>().asFeature(aMachines);
          },
          onDestroyFeature: (_) async {},
        )
        .run(
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
