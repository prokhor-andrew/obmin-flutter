// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.


part of 'zoomable_lib.dart';

extension RenderWidgetExtension<State, Event> on Zoomable<State, Event> {
  Widget render({
    Key? key,
    required Widget Function(BuildContext context, State state, void Function(Event event) update) builder,
  }) {
    return RenderWidget<State, Event>(this, key: key, builder: builder);
  }
}

class RenderWidget<State, Event> extends StatelessWidget {
  final Zoomable<State, Event> zoomable;
  final Widget Function(BuildContext context, State state, void Function(Event event) update) builder;

  const RenderWidget(
    this.zoomable, {
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return zoomable.build<(State, void Function(Event))>(
      key: key,
      processor: (context, state, input, update) {
        return (input, update);
      },
      builder: (context, state) {
        return builder(context, state.$1, state.$2);
      },
    );
  }
}
