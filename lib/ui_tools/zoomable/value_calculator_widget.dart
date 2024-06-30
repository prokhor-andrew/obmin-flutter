// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/types/optional.dart';
import 'package:obmin/ui_tools/zoomable/calculator_widget.dart';
import 'package:obmin/ui_tools/zoomable/zoomable_widget.dart';

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

typedef ValueCalculatorWidget<T> = CalculatorWidget<T, T Function(T)>;
