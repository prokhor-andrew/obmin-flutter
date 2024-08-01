// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/core/core_widget.dart';
import 'package:obmin/machine_ext/distinct_until_changed_machine.dart';

WidgetMachine<State, State, Event> WidgetMachineX<State, Event>({
  required String id,
  required Widget Function(BuildContext context, State state, void Function(Event event)? update) builder,
  bool isDistinctUntilChanged = true,
}) {
  return WidgetMachine.create<(State, void Function(Event event)?), State, State, Event>(
    id: id,
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
  ).transform((machine) {
    return isDistinctUntilChanged ? machine.distinctUntilChangedInput() : machine;
  });
}
