// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.


part of 'zoomable_lib.dart';

class ZoomableConsumerWidget<S, Input, Output> extends StatefulWidget {
  final Zoomable<Input, Output> zoomable;
  final S Function(BuildContext? Function() context, Optional<S> state, Input input, void Function(Output output) update) processor;
  final Widget Function(BuildContext context, S state) builder;

  const ZoomableConsumerWidget({
    super.key,
    required this.zoomable,
    required this.processor,
    required this.builder,
  });

  @override
  State<ZoomableConsumerWidget<S, Input, Output>> createState() => _ConsumerZoomableWidgetState<S, Input, Output>();
}

class _ConsumerZoomableWidgetState<S, Input, Output> extends State<ZoomableConsumerWidget<S, Input, Output>> {
  Optional<S> _state = None();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final (input, update) = widget.zoomable._data(context);

    _state = Some(widget.processor(() => mounted ? context : null, _state, input, update));
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state.force());
  }
}
