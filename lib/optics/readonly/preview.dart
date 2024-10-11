// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/types/non_empty_set.dart';
import 'package:obmin/types/optional.dart';

final class Preview<Whole, Part> {
  final Optional<Part> Function(Whole whole) get;

  const Preview(this.get);

  Preview<Whole, R> zipWith<Part2, R>(
    Preview<Whole, Part2> other,
    R Function(Part value1, Part2 value2) function,
  ) {
    return Preview((whole) {
      return get(whole).bind((value1) {
        return other.get(whole).map((value2) {
          return (value1, value2);
        });
      }).map((tuple) {
        final value1 = tuple.$1;
        final value2 = tuple.$2;
        return function(value1, value2);
      });
    });
  }

  Preview<Whole, R> zipWithEqv<R>(
    Eqv<Whole> other,
    R Function(Part value1, Whole value2) function,
  ) {
    return zipWith(other.asPreview(), function);
  }

  Preview<Whole, R> zipWithGetter<Part2, R>(
    Getter<Whole, Part2> other,
    R Function(Part value1, Part2 value2) function,
  ) {
    return zipWith(other.asPreview(), function);
  }

  FoldSet<Whole, R> zipWithFoldSet<Part2, R>(
    FoldSet<Whole, Part2> other,
    NonEmptySet<R> Function(Part value1, NonEmptySet<Part2> value) function,
  ) {
    return asFoldSet().zipWith(
      other,
      (value1, value2) {
        return function(value1.any, value2);
      },
    );
  }

  Preview<Whole, Sub> compose<Sub>(Preview<Part, Sub> other) {
    return Preview((whole) {
      return get(whole).bind(other.get);
    });
  }

  Preview<Whole, Part> composeWithEqv(Eqv<Part> other) {
    return compose(other.asPreview());
  }

  Preview<Whole, Sub> composeWithGetter<Sub>(Getter<Part, Sub> other) {
    return compose(other.asPreview());
  }

  FoldSet<Whole, Sub> composeWithFoldSet<Sub>(FoldSet<Part, Sub> other) {
    return asFoldSet().compose(other);
  }

  @override
  String toString() {
    return "Preview<$Whole, $Part>";
  }

  Getter<Whole, Optional<Part>> asGetter() {
    return Getter(get);
  }

  FoldSet<Whole, Part> asFoldSet() {
    return FoldSet((whole) {
      return get(whole).map((value) => {value}).valueOr({});
    });
  }
}
