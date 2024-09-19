// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/core/core_widget.dart';
import 'package:obmin/core/core_x/widget_machine_x.dart';
import 'package:obmin/types/update.dart';

WidgetMachine<State, State, Update<State>> WidgetMachineY<State>({
  required String id,
  required Widget Function(BuildContext context) stopped,
  required Widget Function(BuildContext context, Stream<State> Function() states, void Function(Update<State> output) callback) started,
}) {
  return WidgetMachineX<State, Update<State>>(
    id: id,
    stopped: stopped,
    started: started,
  );
}
