// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/core/core.dart';
import 'package:obmin/core/core_widget.dart';
import 'package:obmin/core/core_x/core_x_widget.dart';
import 'package:obmin/types/transition.dart';

CoreWidget<State, State, Transition<State>> CoreYWidget<State>({
  required Core<State, State, Transition<State>> core,
  required WidgetMachine<State, State, Transition<State>> uiMachine,
}) {
  return CoreXWidget<State, Transition<State>>(
    core: core,
    uiMachine: uiMachine,
  );
}
