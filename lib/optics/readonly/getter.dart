// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:meta/meta.dart';
import 'package:obmin/fp/non_empty_set.dart';
import 'package:obmin/fp/optional.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/preview.dart';

@immutable
final class Getter<Whole, Part> {

  @useResult
  final Part Function(Whole whole) get;

  const Getter(this.get);

  @useResult
  Getter<Whole, Sub> compose<Sub>(Getter<Part, Sub> other) {
    return Getter((whole) {
      return other.get(get(whole));
    });
  }

  @useResult
  Getter<Whole, Part> composeWithEqv(Eqv<Part> other) {
    return compose(other.asGetter());
  }

  @useResult
  Preview<Whole, Sub> composeWithPreview<Sub>(Preview<Part, Sub> other) {
    return asPreview().compose(other);
  }

  @useResult
  FoldSet<Whole, Sub> composeWithFoldSet<Sub>(FoldSet<Part, Sub> other) {
    return asFoldSet().compose(other);
  }

  @useResult
  Getter<Whole, R> zipWith<Part2, R>(
    Getter<Whole, Part2> other,
    R Function(Part value1, Part2 value2) function,
  ) {
    return Getter((whole) {
      final part1 = get(whole);
      final part2 = other.get(whole);
      final result = function(part1, part2);

      return result;
    });
  }

  @useResult
  Getter<Whole, R> zipWithEqv<R>(
    Eqv<Whole> other,
    R Function(Part value1, Whole value2) function,
  ) {
    return zipWith(other.asGetter(), function);
  }

  @useResult
  Preview<Whole, R> zipWithPreview<Part2, R>(
    Preview<Whole, Part2> other,
    R Function(Part value1, Part2 value2) function,
  ) {
    return asPreview().zipWith(other, function);
  }

  @useResult
  FoldSet<Whole, R> zipWithFoldSet<Part2, R>(
    FoldSet<Whole, Part2> other,
    NonEmptySet<R> Function(Part value1, NonEmptySet<Part2> value2) function,
  ) {
    return asFoldSet().zipWith(other, (value1, value2) {
      return function(value1.any, value2);
    });
  }

  @useResult
  @override
  String toString() {
    return "Getter<$Whole, $Part>";
  }

  @useResult
  Preview<Whole, Part> asPreview() {
    return Preview((whole) {
      return Optional<Part>.some(get(whole));
    });
  }

  @useResult
  FoldSet<Whole, Part> asFoldSet() {
    return asPreview().asFoldSet();
  }
}
