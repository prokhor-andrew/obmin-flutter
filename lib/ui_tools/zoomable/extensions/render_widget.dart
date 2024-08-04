// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

part of '../zoomable_lib.dart';

extension RenderWidgetExtension<State> on Zoomable<State> {
  Widget render({
    Key? key,
    required Widget Function(BuildContext context, State state) builder,
  }) {
    return RenderWidget<State>(this, key: key, builder: builder);
  }
}

final class RenderWidget<State> extends StatelessWidget {
  final Zoomable<State> zoomable;
  final Widget Function(BuildContext context, State state) builder;

  const RenderWidget(
    this.zoomable, {
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return zoomable.consume<State>(
      key: key,
      processor: (context, state, input) {
        return input;
      },
      builder: (context, state) {
        return builder(context, state);
      },
    );
  }
}
