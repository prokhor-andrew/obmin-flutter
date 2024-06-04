// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/a_foundation/types/writer.dart';
import 'package:obmin/c_core/core.dart';
import 'package:obmin/c_core/core_widget.dart';
import 'package:obmin/c_core/core_x_widget.dart';

CoreWidget<(State, void Function(Writer<State, Loggable> Function(State))?), State, State, Writer<State, Loggable> Function(State), Loggable>
    CoreYWidget<State, Loggable>({
  required Core<State, State, Writer<State, Loggable> Function(State state), Loggable> core,
  required Widget Function(BuildContext context, State state, void Function(Writer<State, Loggable> Function(State state) reducer)? update) builder,
}) {
  return CoreXWidget<State, Writer<State, Loggable> Function(State), Loggable>(
    core: core,
    builder: builder,
  );
}
