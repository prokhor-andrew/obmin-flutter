// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

part of 'zoomable_lib.dart';

extension ZoomableConsumerWidgetExtension<T> on Zoomable<T> {
  Widget consume<S>({
    Key? key,
    required S Function(BuildContext? Function() context, Optional<S> state, T value) processor,
    required Widget Function(BuildContext context, S state) builder,
  }) {
    return ZoomableConsumerWidget<S, T>(
      key: key,
      zoomable: this,
      processor: processor,
      builder: builder,
    );
  }
}

final class ZoomableConsumerWidget<S, T> extends StatefulWidget {
  final Zoomable<T> zoomable;
  final S Function(BuildContext? Function() context, Optional<S> state, T value) processor;
  final Widget Function(BuildContext context, S state) builder;

  const ZoomableConsumerWidget({
    super.key,
    required this.zoomable,
    required this.processor,
    required this.builder,
  });

  @override
  State<ZoomableConsumerWidget<S, T>> createState() => _ConsumerZoomableWidgetState<S, T>();
}

final class _ConsumerZoomableWidgetState<S, T> extends State<ZoomableConsumerWidget<S, T>> {
  Optional<S> _state = Optional<S>.none();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final value = widget.zoomable._data(context);

    _state = Optional<S>.some(widget.processor(() => mounted ? context : null, _state, value));
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state.force());
  }
}
