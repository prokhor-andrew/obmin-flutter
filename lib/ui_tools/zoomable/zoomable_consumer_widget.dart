// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

part of 'zoomable_lib.dart';

extension ZoomableConsumerWidgetExtension<Input> on Zoomable<Input> {
  Widget consume<S>({
    Key? key,
    required S Function(BuildContext? Function() context, Optional<S> state, Input input) processor,
    required Widget Function(BuildContext context, S state) builder,
  }) {
    return ZoomableConsumerWidget<S, Input>(
      key: key,
      zoomable: this,
      processor: processor,
      builder: builder,
    );
  }
}

final class ZoomableConsumerWidget<S, Input> extends StatefulWidget {
  final Zoomable<Input> zoomable;
  final S Function(BuildContext? Function() context, Optional<S> state, Input input) processor;
  final Widget Function(BuildContext context, S state) builder;

  const ZoomableConsumerWidget({
    super.key,
    required this.zoomable,
    required this.processor,
    required this.builder,
  });

  @override
  State<ZoomableConsumerWidget<S, Input>> createState() => _ConsumerZoomableWidgetState<S, Input>();
}

final class _ConsumerZoomableWidgetState<S, Input> extends State<ZoomableConsumerWidget<S, Input>> {
  Optional<S> _state = Optional<S>.none();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final input = widget.zoomable._data(context);

    _state = Optional<S>.some(widget.processor(() => mounted ? context : null, _state, input));
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state.force());
  }
}
