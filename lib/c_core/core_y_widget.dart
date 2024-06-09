// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/c_core/core.dart';
import 'package:obmin/c_core/core_widget.dart';
import 'package:obmin/c_core/core_x_widget.dart';

CoreWidget<(State, void Function(State Function(State))?), State, State, State Function(State)> CoreYWidget<State>({
  required Core<State, State, State Function(State state)> core,
  required Widget Function(BuildContext context, State state, void Function(State Function(State state) reducer)? update) builder,
}) {
  return CoreXWidget<State, State Function(State)>(
    core: core,
    builder: builder,
  );
}
