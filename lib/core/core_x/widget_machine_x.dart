// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/core/core_widget.dart';
import 'package:obmin/machine_ext/silo_machine.dart';

WidgetMachine<State, State, Event> WidgetMachineX<State, Event>({
  required String id,
  required Widget Function(BuildContext context) stopped,
  required Widget Function(BuildContext context, Silo<State> Function() states, void Function(Event output) callback) started,
}) {
  return WidgetMachine.create<State, State, Event>(
    id: id,
    stopped: stopped,
    started: started,
  );
}
