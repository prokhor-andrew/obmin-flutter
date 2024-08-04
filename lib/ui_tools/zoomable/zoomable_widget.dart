// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

part of 'zoomable_lib.dart';

final class ZoomableWidget<Input> extends InheritedWidget {
  final Input input;

  ZoomableWidget({
    super.key,
    required this.input,
    required Widget Function(BuildContext context, Zoomable<Input> zoomable) builder,
  }) : super(child: _ZoomableStatelessWidget<Input>(builder: builder));

  static ZoomableWidget<Input> _of<Input>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ZoomableWidget<Input>>()!;
  }

  @override
  bool updateShouldNotify(ZoomableWidget<Input> oldWidget) {
    return input != oldWidget.input;
  }
}

final class _ZoomableStatelessWidget<Input> extends StatelessWidget {
  final Widget Function(BuildContext context, Zoomable<Input> zoomable) builder;

  const _ZoomableStatelessWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final zoomable = Zoomable<Input>._((context) {
      final widget = ZoomableWidget._of<Input>(context);
      final input = widget.input;

      return input;
    });

    return builder(context, zoomable);
  }
}