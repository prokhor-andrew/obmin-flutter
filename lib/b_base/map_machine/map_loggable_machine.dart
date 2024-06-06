// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/machine.dart';
import 'package:obmin/a_foundation/machine_logger.dart';

extension MapLoggableMachine<Input, Output, Loggable> on Machine<Input, Output, Loggable> {
  Machine<Input, Output, R> mapLoggable<R>(R Function(Loggable loggable) function) {
    return Machine(
      id: id,
      onCreate: (logger) {
        return onCreate(
          MachineLogger(
            id: logger.id,
            log: (loggable) {
              logger.log(function(loggable));
            },
          ),
        );
      },
    );
  }
}
