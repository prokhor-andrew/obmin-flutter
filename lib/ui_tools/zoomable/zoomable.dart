// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

part of 'zoomable_lib.dart';

final class Zoomable<Input> {
  final Input Function(BuildContext context) _data;

  const Zoomable._(this._data);

  Zoomable<R> map<R>(R Function(Input value) function) {
    return Zoomable._(
      (context) {
        final input = _data(context);

        return function(input);
      },
    );
  }
}
