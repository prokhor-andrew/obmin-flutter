// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

part of '../zoomable_lib.dart';

extension CalculatorWidgetExtension<State> on Zoomable<State> {
  Widget calculator({
    Key? key,
    required void Function(BuildContext context, Optional<State> oldState, State newState) calculate,
    required Widget child,
  }) {
    return CalculatorWidget<State>(
      this,
      key: key,
      calculate: calculate,
      child: child,
    );
  }
}

final class CalculatorWidget<State> extends StatelessWidget {
  final Zoomable<State> zoomable;
  final void Function(BuildContext context, Optional<State> oldState, State newState) calculate;
  final Widget child;

  const CalculatorWidget(
    this.zoomable, {
    super.key,
    required this.calculate,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return zoomable.consume<State>(
      key: key,
      processor: (context, state, input) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = context();
          if (ctx != null) {
            calculate(ctx, state, input);
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
