// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/c_core/core.dart';
import 'package:obmin/c_core/core_widget.dart';

CoreWidget<(State, void Function(Event event)?), State, State, Event, Loggable> CoreXWidget<State, Event, Loggable>({
  required Core<State, State, Event, Loggable> core,
  required Widget Function(BuildContext context, State state, void Function(Event event)? update) builder,
}) {
  return CoreWidget<(State, void Function(Event event)? update), State, State, Event, Loggable>(
    core: core,
    init: (state) {
      return (state, null);
    },
    activate: (initial, update) {
      return (initial.$1, update);
    },
    process: (cur, input) {
      return (input, cur.$2);
    },
    build: (context, pack) {
      final (state, update) = pack;
      return builder(context, state, update);
    },
  );
}
