// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

part of 'zoomable_lib.dart';

extension ValueCalculatorWidgetExtension<T> on Zoomable<T, Transition<T>> {
  Widget valueCalculator({
    Key? key,
    required void Function(BuildContext context, Optional<T> oldState, T newState, void Function(Transition<T> transition) update) calculate,
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

typedef ValueCalculatorWidget<T> = CalculatorWidget<T, Transition<T>>;
