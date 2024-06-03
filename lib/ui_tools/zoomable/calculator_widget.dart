// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/ui_tools/zoomable/zoomable_widget.dart';

extension CalculatorWidgetExtension<State, Event> on Zoomable<State, Event> {
  Widget calculator({
    Key? key,
    required void Function(BuildContext context, Optional<State> oldState, State newState, void Function(Event event) update) calculate,
    required Widget child,
  }) {
    return CalculatorWidget<State, Event>(
      this,
      key: key,
      calculate: calculate,
      child: child,
    );
  }
}

class CalculatorWidget<State, Event> extends StatelessWidget {
  final Zoomable<State, Event> zoomable;
  final void Function(BuildContext context, Optional<State> oldState, State newState, void Function(Event event) update) calculate;
  final Widget child;

  const CalculatorWidget(
    this.zoomable, {
    super.key,
    required this.calculate,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return zoomable.build<State>(
      key: key,
      processor: (context, state, input, update) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = context();
          if (ctx != null) {
            calculate(ctx, state, input, update);
          }
        });

        return input;
      },
      builder: (context, state) {
        return child;
      },
    );
  }
}
