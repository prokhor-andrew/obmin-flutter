// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'dart:async';

import 'package:obmin/machine/machine_factory.dart';
import 'package:obmin/machine_ext/silo_machine.dart';
import 'package:obmin/machine_ext/stream_machine.dart';

extension FutureMachine on MachineFactory {
  Silo<Res> future<Res>({
    required String id,
    required Future<Res> Function() future,
  }) {
    return MachineFactory.shared.stream<Res>(
      id: id,
      stream: () {
        return future().asStream();
      },
    );
  }
}
