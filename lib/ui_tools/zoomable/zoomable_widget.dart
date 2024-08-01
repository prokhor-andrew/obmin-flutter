// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

part of 'zoomable_lib.dart';

final class ZoomableWidget<Input, Output> extends InheritedWidget {
  final Input input;
  final void Function(Output) update;

  ZoomableWidget({
    super.key,
    required this.input,
    required this.update,
    required Widget Function(BuildContext context, Zoomable<Input, Output> zoomable) builder,
  }) : super(child: _ZoomableStatelessWidget<Input, Output>(builder: builder));

  static ZoomableWidget<Input, Output> _of<Input, Output>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ZoomableWidget<Input, Output>>()!;
  }

  @override
  bool updateShouldNotify(ZoomableWidget<Input, Output> oldWidget) {
    return input != oldWidget.input;
  }
}

final class _ZoomableStatelessWidget<Input, Output> extends StatelessWidget {
  final Widget Function(BuildContext context, Zoomable<Input, Output> zoomable) builder;

  const _ZoomableStatelessWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final zoomable = Zoomable<Input, Output>._((context) {
      final widget = ZoomableWidget._of<Input, Output>(context);
      final input = widget.input;
      final update = widget.update;

      return (input, update);
    });

    return builder(context, zoomable);
  }
}