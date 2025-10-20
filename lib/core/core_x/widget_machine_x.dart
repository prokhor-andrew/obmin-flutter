// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:obmin/obmin.dart';
import 'package:obmin_flutter/core/core_widget.dart';

WidgetMachine<State, State, Event> WidgetMachineX<State, Event>({
  required Widget Function(BuildContext context, ValueListenable<(State state, Option<void Function(Event event)> update)>) builder,
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
    build: (context, notifier) {
      return builder(context, notifier);
    },
  ).transform((machine) {
    return isDistinctUntilChanged ? machine.distinctUntilChangedInput(shouldWaitOnEffects: false) : machine;
  });
}
