// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'dart:async';

import 'package:obmin/a_foundation/machine_factory.dart';
import 'package:obmin/b_base/chamber_machine/silo_machine.dart';

extension FeatureMachine on MachineFactory {
  Silo<Res> future<Res>({
    required String id,
    required Future<Res> Function() call,
  }) {
    return MachineFactory.shared.silo<StreamSubscription<Res>, Res>(
      id: id,
      onStart: (callback) {
        return call().asStream().listen(callback);
      },
      onStop: (sub) {
        sub.cancel();
      },
    );
  }
}
