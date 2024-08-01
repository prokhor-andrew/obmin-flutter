// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'dart:async';

import 'package:obmin/machine/machine_factory.dart';
import 'package:obmin/machine_ext/silo_machine.dart';

extension StreamMachineExtension on MachineFactory {
  Silo<Res> stream<Res>({
    required String id,
    required Stream<Res> Function() stream,
  }) {
    return MachineFactory.shared.silo<StreamSubscription<Res>, Res>(
      id: id,
      onStart: (callback) {
        return stream().listen(callback);
      },
      onStop: (sub) {
        sub.cancel();
      },
    );
  }
}
