// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/core/core.dart';
import 'package:obmin/core/core_x/core_x.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/types/func.dart';

Core<State, State, Func<State, State>> CoreY<State>({
  required State Function() state,
  required IMap<String, Machine<State, Func<State, State>>> Function(State state) machines,
}) {
  return CoreX(
    state: state,
    reducer: (state, reducer) {
      return reducer(state);
    },
    machines: machines,
  );
}
