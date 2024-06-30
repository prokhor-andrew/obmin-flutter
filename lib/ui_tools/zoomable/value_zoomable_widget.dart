// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/ui_tools/zoomable/zoomable_widget.dart';

class ValueZoomable<T> extends StatelessWidget {
  final T value;
  final void Function(T Function(T) transition) update;
  final Widget Function(BuildContext context, Zoomable<T, T Function(T)> zoomable) builder;

  const ValueZoomable({
    super.key,
    required this.value,
    required this.update,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ZoomableWidget<T, T Function(T)>(
      input: value,
      update: update,
      builder: builder,
    );
  }
}
