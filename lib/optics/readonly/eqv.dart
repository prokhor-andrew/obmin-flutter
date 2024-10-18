// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/fp/non_empty_set.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

final class Eqv<T> {
  const Eqv();

  T identity(T value) => value;

  Eqv<T> compose(Eqv<T> other) {
    return const Eqv();
  }

  Mutator<Whole, Whole> asMutator<Whole>() {
    return Mutator.identity<Whole>();
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

  FoldSet<T, R> zipWithFoldSet<Part, R>(
    FoldSet<T, Part> other,
    NonEmptySet<R> Function(T value1, NonEmptySet<Part> value2) function,
  ) {
    return asFoldSet().zipWith(other, (value1, value2) {
      return function(value1.any, value2);
    });
  }

  Getter<T, R> composeWithGetter<R>(Getter<T, R> other) {
    return asGetter().compose(other);
  }

  Preview<T, R> composeWithPreview<R>(Preview<T, R> other) {
    return asPreview().compose(other);
  }

  FoldSet<T, R> composeWithFoldSet<R>(FoldSet<T, R> other) {
    return asFoldSet().compose(other);
  }

  Getter<T, T> asGetter() {
    return Getter(identity);
  }

  Preview<T, T> asPreview() {
    return asGetter().asPreview();
  }

  FoldSet<T, T> asFoldSet() {
    return asGetter().asFoldSet();
  }

  @override
  String toString() {
    return "Eqv<$T>";
  }
}
