// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/ui_tools/zoomable/render_widget.dart';
import 'package:obmin/ui_tools/zoomable/zoomable_widget.dart';

extension ValueRenderWidgetExtension<T> on Zoomable<T, T Function(T)> {
  Widget valueRender({
    Key? key,
    required Widget Function(BuildContext context, T state, void Function(T Function(T value) transition) update) builder,
  }) {
    return ValueRenderWidget<T>(this, key: key, builder: builder);
  }
}

typedef ValueRenderWidget<T> = RenderWidget<T, T Function(T)>;
