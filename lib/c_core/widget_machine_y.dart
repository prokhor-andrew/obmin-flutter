// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/c_core/core_widget.dart';
import 'package:obmin/c_core/widget_machine_x.dart';

WidgetMachine<State, State, State Function(State)> WidgetMachineY<State>({
  required String id,
  required Widget Function(BuildContext context, State state, void Function(State Function(State state) reducer)? update) builder,
}) {
  return WidgetMachineX<State, State Function(State)>(
    id: id,
    builder: builder,
  );
}
