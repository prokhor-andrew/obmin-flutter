// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/c_core/core.dart';
import 'package:obmin/c_core/core_widget.dart';

CoreWidget<State, State, Event> CoreXWidget<State, Event>({
  required Core<State, State, Event> core,
  required WidgetMachine<State, State, Event> uiMachine,
}) {
  return CoreWidget<State, State, Event>(
    core: core,
    uiMachine: uiMachine,
  );
}
