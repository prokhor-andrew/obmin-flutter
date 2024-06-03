// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/machine.dart';
import 'package:obmin/a_foundation/machine_factory.dart';
import 'package:obmin/a_foundation/machine_logger.dart';

extension BasicMachine on MachineFactory {
  Machine<Input, Output, Loggable> create<Object, Input, Output, Loggable>({
    required String id,
    required Object Function(String id, MachineLogger<Loggable> logger) onCreate,
    required Future<void> Function(Object object, void Function(Output output)? callback) onChange,
    required Future<void> Function(Object object, Input input) onProcess,
  }) {
    return Machine<Input, Output, Loggable>(
      id: id,
      onCreate: (logger) {
        final Object object = onCreate(id, logger);

        return (
          (callback) async {
            await onChange(object, callback);
          },
          (input) async {
            await onProcess(object, input);
          },
        );
      },
    );
  }
}
