// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/core/core.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/core/core_x/core_x.dart';

Core<State, State, State Function(State state)> CoreY<State>({
  required State Function() state,
  required Set<Machine<State, State Function(State state)>> Function(State state) machines,
}) {
  return CoreX(
    state: state,
    reducer: (state, reducer) {
      return reducer(state);
    },
    machines: machines,
  );
}