import 'package:flutter/material.dart';
import 'package:obmin_concept/a_foundation/types/lens.dart';
import 'package:obmin_concept/a_foundation/types/optional.dart';

class ZoomableWidget<Input, Output> extends InheritedWidget {
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

class _ZoomableStatelessWidget<Input, Output> extends StatelessWidget {
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

final class Zoomable<Input, Output> {
  final (Input input, void Function(Output) update) Function(BuildContext context) _data;

  Zoomable._(this._data);

  Zoomable<R, Output> mapInput<R>(R Function(Input value) function) {
    return Zoomable._(
      (context) {
        final (input, send) = _data(context);

        return (
          function(input),
          send,
        );
      },
    );
  }

  Zoomable<Input, R> mapOutput<R>(Output Function(R value) function) {
    return Zoomable._(
      (context) {
        final (input, update) = _data(context);

        return (
          input,
          (event) {
            update(function(event));
          },
        );
      },
    );
  }

  Widget build<S>({
    Key? key,
    required S Function(BuildContext? Function() context, Optional<S> state, Input input, void Function(Output output) update) processor,
    required Widget Function(BuildContext context, S state) builder,
  }) {
    return ConsumerZoomableWidget<S, Input, Output>(
      key: key,
      zoomable: this,
      processor: processor,
      builder: builder,
    );
  }
}

extension ValueZoomable<T> on Zoomable<T, T Function(T value)> {
  Zoomable<V, V Function(V)> zoom<V>(Lens<T, V> lens) {
    return mapInput(lens.get).mapOutput((update) {
      return (whole) {
        return lens.put(whole, update(lens.get(whole)));
      };
    });
  }
}

class ConsumerZoomableWidget<S, Input, Output> extends StatefulWidget {
  final Zoomable<Input, Output> zoomable;
  final S Function(BuildContext? Function() context, Optional<S> state, Input input, void Function(Output output) update) processor;
  final Widget Function(BuildContext context, S state) builder;

  const ConsumerZoomableWidget({
    super.key,
    required this.zoomable,
    required this.processor,
    required this.builder,
  });

  @override
  State<ConsumerZoomableWidget<S, Input, Output>> createState() => _ConsumerZoomableWidgetState<S, Input, Output>();
}

class _ConsumerZoomableWidgetState<S, Input, Output> extends State<ConsumerZoomableWidget<S, Input, Output>> {
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
