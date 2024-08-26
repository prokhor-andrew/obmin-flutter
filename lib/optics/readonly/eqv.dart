// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/fold.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/types/non_empty_iterable.dart';

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

  Fold<T, R> zipWithFold<Part, R>(
    Fold<T, Part> other,
    NonEmptyIterable<R> Function(T value1, NonEmptyIterable<Part> value2) function,
  ) {
    return asFold().zipWith(other, (value1, value2) {
      return function(value1.head, value2);
    });
  }

  Getter<T, R> composeWithGetter<R>(Getter<T, R> other) {
    return asGetter().compose(other);
  }

  Preview<T, R> composeWithPreview<R>(Preview<T, R> other) {
    return asPreview().compose(other);
  }

  Fold<T, R> composeWithFold<R>(Fold<T, R> other) {
    return asFold().compose(other);
  }

  Getter<T, T> asGetter() {
    return Getter(identity);
  }

  Preview<T, T> asPreview() {
    return asGetter().asPreview();
  }

  Fold<T, T> asFold() {
    return asGetter().asFold();
  }

  @override
  String toString() {
    return "Eqv<$T>";
  }
}
