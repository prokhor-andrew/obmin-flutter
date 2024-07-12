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
}
