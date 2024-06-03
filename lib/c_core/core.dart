// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/machine.dart';
import 'package:obmin/a_foundation/machine_factory.dart';
import 'package:obmin/a_foundation/machine_logger.dart';
import 'package:obmin/a_foundation/types/writer.dart';
import 'package:obmin/b_base/feature_machine/feature_machine.dart';
import 'package:obmin/b_base/feature_machine/scene.dart';

final class Core<State, Input, Output, Loggable> {
  final Scene<State, Output, Input, Loggable> Function() scene;
  final Set<Machine<Input, Output, Loggable>> Function(State state) machines;
  final Set<MachineLogger<Loggable>> Function() loggers;

  Process<void>? _process;

  Core({
    required this.scene,
    required this.machines,
    required this.loggers,
  });

  bool get isStarted => _process != null;

  bool start() {
    if (_process != null) {
      return false;
    }

    final aScene = scene();
    final aLoggers = loggers();
    final aMachines = machines(aScene.state);

    _process = MachineFactory.shared
        .feature(
          id: "core",
          feature: () {
            return Writer(aScene.asIntTriggerIntEffect().asFeature(aMachines));
          },
        )
        .run(
          logger: MachineLogger(
            id: "merged",
            log: (loggable) {
              for (final logger in aLoggers) {
                logger.log(loggable);
              }
            },
          ),
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
