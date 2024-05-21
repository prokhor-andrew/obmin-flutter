import 'package:flutter/material.dart';

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

  Widget build({
    Key? key,
    required Widget Function(
      BuildContext context,
      Input input,
      void Function(Output event) update,
    ) builder,
  }) {
    return Builder(
      key: key,
      builder: (context) {
        final (input, update) = _data(context);
        return builder(context, input, update);
      },
    );
  }
}

extension ValueZoomable<T> on Zoomable<T, T Function(T value)> {
  Zoomable<V, V Function(V)> zoom<V>({
    required V Function(T part) get,
    required T Function(T whole, V part) put,
  }) {
    return mapInput(get).mapOutput((update) {
      return (whole) {
        return put(whole, update(get(whole)));
      };
    });
  }
}
