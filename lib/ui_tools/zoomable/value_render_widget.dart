import 'package:flutter/material.dart';
import 'package:obmin_concept/ui_tools/zoomable/render_widget.dart';
import 'package:obmin_concept/ui_tools/zoomable/zoomable_widget.dart';

extension ValueRenderWidgetExtension<T> on Zoomable<T, T Function(T)> {
 
  Widget valueRender({
    Key? key,
    required Widget Function(BuildContext context, T state, void Function(T Function(T value) transition) update) builder,
  }) {
    return ValueRenderWidget(this, key: key, builder: builder);
  }
}

class ValueRenderWidget<T> extends StatelessWidget {
  final Zoomable<T, T Function(T)> zoomable;
  final Widget Function(BuildContext context, T state, void Function(T Function(T) transition) update) builder;

  const ValueRenderWidget(
    this.zoomable, {
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return zoomable.render(key: key, builder: builder);
  }
}
