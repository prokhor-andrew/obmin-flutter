// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/core/core_widget.dart';
import 'package:obmin/types/option.dart';

WidgetMachine<State, State, Event> WidgetMachineX<State, Event>({
  required Widget Function(BuildContext context, State state, Option<void Function(Event event)> update) builder,
  bool isDistinctUntilChanged = true,
}) {
  return WidgetMachine.create<(State, Option<void Function(Event event)>), State, State, Event>(
    init: (state) {
      return (state, Option.none());
    },
    activate: (initial, update) {
      return (initial.$1, Option.some(update));
    },
    process: (cur, input) {
      return (input, cur.$2);
    },
    build: (context, pack) {
      final (state, update) = pack;
      return builder(context, state, update);
    },
  ).transform((machine) {
    return isDistinctUntilChanged ? machine.distinctUntilChangedInput(shouldWaitOnEffects: false) : machine;
  });
}
