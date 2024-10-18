// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:meta/meta.dart';
import 'package:obmin/fp/non_empty_set.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

@immutable
final class Eqv<T> {

  @literal
  const Eqv();

  @useResult
  T identity(T value) => value;

  @useResult
  Eqv<T> compose(Eqv<T> other) {
    return const Eqv();
  }

  @useResult
  Mutator<Whole, Whole> asMutator<Whole>() {
    return Mutator.identity<Whole>();
  }

  @useResult
  Getter<T, R> zipWithGetter<Part, R>(
    Getter<T, Part> other,
    R Function(T value1, Part value2) function,
  ) {
    return asGetter().zipWith(other, function);
  }

  @useResult
  Preview<T, R> zipWithPreview<Part, R>(
    Preview<T, Part> other,
    R Function(T value1, Part value2) function,
  ) {
    return asPreview().zipWith(other, function);
  }

  @useResult
  FoldSet<T, R> zipWithFoldSet<Part, R>(
    FoldSet<T, Part> other,
    NonEmptySet<R> Function(T value1, NonEmptySet<Part> value2) function,
  ) {
    return asFoldSet().zipWith(other, (value1, value2) {
      return function(value1.any, value2);
    });
  }

  @useResult
  Getter<T, R> composeWithGetter<R>(Getter<T, R> other) {
    return asGetter().compose(other);
  }

  @useResult
  Preview<T, R> composeWithPreview<R>(Preview<T, R> other) {
    return asPreview().compose(other);
  }

  @useResult
  FoldSet<T, R> composeWithFoldSet<R>(FoldSet<T, R> other) {
    return asFoldSet().compose(other);
  }

  @useResult
  Getter<T, T> asGetter() {
    return Getter(identity);
  }

  @useResult
  Preview<T, T> asPreview() {
    return asGetter().asPreview();
  }

  @useResult
  FoldSet<T, T> asFoldSet() {
    return asGetter().asFoldSet();
  }

  @useResult
  @override
  String toString() {
    return "Eqv<$T>";
  }
}
