import 'package:flutter/material.dart';
import 'package:obmin_concept/a_foundation/types/optional.dart';
import 'package:obmin_concept/ui_tools/zoomable/calculator_widget.dart';
import 'package:obmin_concept/ui_tools/zoomable/zoomable_widget.dart';

extension ValueCalculatorWidgetExtension<T> on Zoomable<T, T Function(T)> {
  Widget valueCalculator({
    Key? key,
    required void Function(BuildContext context, Optional<T> oldState, T newState, void Function(T Function(T value) transition) update) calculate,
    required Widget child,
  }) {
    return ValueCalculatorWidget<T>(
      this,
      key: key,
      calculate: calculate,
      child: child,
    );
  }
}

class ValueCalculatorWidget<T> extends StatelessWidget {
  final Zoomable<T, T Function(T)> zoomable;
  final void Function(BuildContext context, Optional<T> oldState, T newState, void Function(T Function(T value) transition) update) calculate;
  final Widget child;

  const ValueCalculatorWidget(
    this.zoomable, {
    super.key,
    required this.calculate,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return zoomable.calculator(
      key: key,
      calculate: calculate,
      child: child,
    );
  }
}