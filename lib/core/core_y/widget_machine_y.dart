// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/core/core_widget.dart';
import 'package:obmin/core/core_x/widget_machine_x.dart';
import 'package:obmin/types/optional.dart';
import 'package:obmin/types/update.dart';

WidgetMachine<State, State, Update<State>> WidgetMachineY<State>({
  required String id,
  required Widget Function(BuildContext context, State state, Optional<void Function(Update<State> transition)> update) builder,
  bool isDistinctUntilChanged = true,
}) {
  return WidgetMachineX<State, Update<State>>(
    id: id,
    builder: builder,
    isDistinctUntilChanged: isDistinctUntilChanged,
  );
}
