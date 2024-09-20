// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/fold_list.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/types/non_empty_list.dart';

final class Eqv<T> {
  const Eqv();

  T identity(T value) => value;

  Eqv<T> compose(Eqv<T> other) {
    return const Eqv();
  }

  Getter<T, R> zipWithGetter<Part, R>(
    Getter<T, Part> other,
    R Function(T value1, Part value2) function,
  ) {
    return asGetter().zipWith(other, function);
  }

  Preview<T, R> zipWithPreview<Part, R>(
    Preview<T, Part> other,
    R Function(T value1, Part value2) function,
  ) {
    return asPreview().zipWith(other, function);
  }

  FoldList<T, R> zipWithFoldList<Part, R>(
    FoldList<T, Part> other,
    NonEmptyList<R> Function(T value1, NonEmptyList<Part> value2) function,
  ) {
    return asFoldList().zipWith(other, (value1, value2) {
      return function(value1.head, value2);
    });
  }

  Getter<T, R> composeWithGetter<R>(Getter<T, R> other) {
    return asGetter().compose(other);
  }

  Preview<T, R> composeWithPreview<R>(Preview<T, R> other) {
    return asPreview().compose(other);
  }

  FoldList<T, R> composeWithFoldList<R>(FoldList<T, R> other) {
    return asFoldList().compose(other);
  }

  Getter<T, T> asGetter() {
    return Getter(identity);
  }

  Preview<T, T> asPreview() {
    return asGetter().asPreview();
  }

  FoldList<T, T> asFoldList() {
    return asGetter().asFoldList();
  }

  @override
  String toString() {
    return "Eqv<$T>";
  }
}
