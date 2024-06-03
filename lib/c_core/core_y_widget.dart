// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/a_foundation/types/writer.dart';
import 'package:obmin/c_core/core.dart';
import 'package:obmin/c_core/core_widget.dart';

CoreWidget<(DomainState, void Function(Writer<DomainState, Loggable> Function(DomainState))?), DomainState, DomainState,
    Writer<DomainState, Loggable> Function(DomainState), Loggable> CoreYWidget<DomainState, Loggable>({
  required Core<DomainState, DomainState, Writer<DomainState, Loggable> Function(DomainState state), Loggable> core,
  required Widget Function(BuildContext context, DomainState state, void Function(Writer<DomainState, Loggable> Function(DomainState state) update)?) builder,
}) {
  return CoreWidget<
      (
      DomainState,
      void Function(Writer<DomainState, Loggable> Function(DomainState state) reducer)? update
      ),
      DomainState,
      DomainState,
      Writer<DomainState, Loggable> Function(DomainState state),
      Loggable
  >(
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
