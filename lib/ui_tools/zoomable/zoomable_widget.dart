// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

part of 'zoomable_lib.dart';

final class ZoomableWidget<T> extends InheritedWidget {
  final T value;

  ZoomableWidget(
    this.value, {
    super.key,
    required Widget Function(BuildContext context, Zoomable<T> zoomable) builder,
  }) : super(child: _ZoomableStatelessWidget<T>(builder: builder));

  static ZoomableWidget<Input> _of<Input>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ZoomableWidget<Input>>()!;
  }

  @override
  bool updateShouldNotify(ZoomableWidget<T> oldWidget) {
    return value != oldWidget.value;
  }
}

final class _ZoomableStatelessWidget<T> extends StatelessWidget {
  final Widget Function(BuildContext context, Zoomable<T> zoomable) builder;

  const _ZoomableStatelessWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final zoomable = Zoomable<T>._((context) {
      final widget = ZoomableWidget._of<T>(context);
      final input = widget.value;

      return input;
    });

    return builder(context, zoomable);
  }
}
