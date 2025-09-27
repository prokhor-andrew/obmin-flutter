// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:obmin/core/core_widget.dart';
import 'package:obmin/core/core_x/widget_machine_x.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/option.dart';

WidgetMachine<State, State, Func<State, State>> WidgetMachineY<State>({
  required Widget Function(BuildContext context, ValueListenable<(State state, Option<void Function(Func<State, State> transition)>)> notifier) builder,
  bool isDistinctUntilChanged = true,
}) {
  return WidgetMachineX<State, Func<State, State>>(
    builder: builder,
    isDistinctUntilChanged: isDistinctUntilChanged,
  );
}
