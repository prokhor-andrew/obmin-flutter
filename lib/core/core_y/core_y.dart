// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/core/core.dart';
import 'package:obmin/core/core_x/core_x.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/optics/readonly/update.dart';

Core<State, State, Update<State>> CoreY<State>({
  required State Function(CoreInitialObject initial) state,
  required ISet<Machine<State, Update<State>>> Function(State state) machines,
}) {
  return CoreX(
    state: state,
    reducer: (state, reducer) {
      return reducer.get(state);
    },
    machines: machines,
  );
}
