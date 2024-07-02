// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/core/core.dart';
import 'package:obmin/core/core_widget.dart';
import 'package:obmin/core/core_x/core_x_widget.dart';
import 'package:obmin/types/optional.dart';

CoreWidget<State, State, Optional<State> Function(State)> CoreYWidget<State>({
  required Core<State, State, Optional<State> Function(State state)> core,
  required WidgetMachine<State, State, Optional<State> Function(State)> uiMachine,
}) {
  return CoreXWidget<State, Optional<State> Function(State)>(
    core: core,
    uiMachine: uiMachine,
  );
}
