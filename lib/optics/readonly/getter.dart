// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/types/non_empty_iterable.dart';
import 'package:obmin/types/optional.dart';

final class Getter<Whole, Part> {
  final Part Function(Whole whole) get;

  const Getter(this.get);

  Getter<Whole, Sub> compose<Sub>(Getter<Part, Sub> other) {
    return Getter((whole) {
      return other.get(get(whole));
    });
  }

  Getter<Whole, Part> composeWithEqv(Eqv<Part> other) {
    return compose(other.asGetter());
  }

  Preview<Whole, Sub> composeWithPreview<Sub>(Preview<Part, Sub> other) {
    return asPreview().compose(other);
  }

  Fold<Whole, Sub> composeWithFold<Sub>(Fold<Part, Sub> other) {
    return asFold().compose(other);
  }

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

  Getter<Whole, R> zipWithEqv<R>(
    Eqv<Whole> other,
    R Function(Part value1, Whole value2) function,
  ) {
    return zipWith(other.asGetter(), function);
  }

  Preview<Whole, R> zipWithPreview<Part2, R>(
    Preview<Whole, Part2> other,
    R Function(Part value1, Part2 value2) function,
  ) {
    return asPreview().zipWith(other, function);
  }

  Fold<Whole, R> zipWithFold<Part2, R>(
    Fold<Whole, Part2> other,
    NonEmptyIterable<R> Function(Part value1, NonEmptyIterable<Part2> value2) function,
  ) {
    return asFold().zipWith(other, (value1, value2) {
      return function(value1.head, value2);
    });
  }

  @override
  String toString() {
    return "Getter<$Whole, $Part>";
  }

  Preview<Whole, Part> asPreview() {
    return Preview((whole) {
      return Optional<Part>.some(get(whole));
    });
  }

  Fold<Whole, Part> asFold() {
    return asPreview().asFold();
  }
}
