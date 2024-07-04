// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

part of 'zoomable_lib.dart';

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
    return ZoomableConsumerWidget<S, Input, Output>(
      key: key,
      zoomable: this,
      processor: processor,
      builder: builder,
    );
  }
}



extension ValueZoomableExtension<T> on Zoomable<T, Transition<T>> {
  Zoomable<V, Transition<V>> zoom<V>(Lens<T, V> lens) {
    return mapInput(lens.get).mapOutput((update) {
      return (whole) {
        return update(lens.get(whole)).map((value) {
          return lens.put(whole, value);
        });
      };
    });
  }
}

