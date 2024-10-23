// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_list.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/types/non_empty_list.dart';
import 'package:obmin/types/non_empty_set.dart';
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

  FoldList<Whole, Sub> composeWithFoldList<Sub>(FoldList<Part, Sub> other) {
    return asFoldList().compose(other);
  }

  FoldSet<Whole, Sub> composeWithFoldSet<Sub>(FoldSet<Part, Sub> other) {
    return asFoldSet().compose(other);
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

  FoldList<Whole, R> zipWithFoldList<Part2, R>(
    FoldList<Whole, Part2> other,
    NonEmptyList<R> Function(Part value1, NonEmptyList<Part2> value2) function,
  ) {
    return asFoldList().zipWith(other, (value1, value2) {
      return function(value1.head, value2);
    });
  }

  FoldSet<Whole, R> zipWithFoldSet<Part2, R>(
    FoldSet<Whole, Part2> other,
    NonEmptySet<R> Function(Part value1, NonEmptySet<Part2> value2) function,
  ) {
    return asFoldSet().zipWith(other, (value1, value2) {
      return function(value1.any, value2);
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

  FoldList<Whole, Part> asFoldList() {
    return asPreview().asFoldList();
  }

  FoldSet<Whole, Part> asFoldSet() {
    return asPreview().asFoldSet();
  }
}
