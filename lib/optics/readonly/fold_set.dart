// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/types/non_empty_set.dart';

final class FoldSet<Whole, Part> {
  final ISet<Part> Function(Whole whole) get;

  const FoldSet(this.get);

  FoldSet<Whole, Sub> compose<Sub>(FoldSet<Part, Sub> other) {
    return FoldSet((whole) {
      return get(whole).expand(other.get).toISet();
    });
  }

  FoldSet<Whole, Part> composeWithEqv(Eqv<Part> other) {
    return compose(other.asFoldSet());
  }

  FoldSet<Whole, Sub> composeWithGetter<Sub>(Getter<Part, Sub> other) {
    return compose(other.asFoldSet());
  }

  FoldSet<Whole, Sub> composeWithPreview<Sub>(Preview<Part, Sub> other) {
    return compose(other.asFoldSet());
  }

  FoldSet<Whole, R> zipWith<Part2, R>(
    FoldSet<Whole, Part2> other,
    NonEmptySet<R> Function(NonEmptySet<Part> value1, NonEmptySet<Part2> value2) function,
  ) {
    return FoldSet((whole) {
      return NonEmptySet.fromISet(get(whole)).bind((value1) {
        return NonEmptySet.fromISet(other.get(whole)).map((value2) {
          return (value1, value2);
        });
      }).map((tuple) {
        final value1 = tuple.$1;
        final value2 = tuple.$2;
        return function(value1, value2).toISet();
      }).valueOr(const ISet.empty());
    });
  }

  FoldSet<Whole, R> zipWithEqv<R>(
    Eqv<Whole> other,
    NonEmptySet<R> Function(NonEmptySet<Part> value1, Whole value2) function,
  ) {
    return zipWith(other.asFoldSet(), (value1, value2) {
      return function(value1, value2.any);
    });
  }

  FoldSet<Whole, R> zipWithGetter<Part2, R>(
    Getter<Whole, Part2> other,
    NonEmptySet<R> Function(NonEmptySet<Part> value1, Part2 value2) function,
  ) {
    return zipWith(other.asFoldSet(), (value1, value2) {
      return function(value1, value2.any);
    });
  }

  FoldSet<Whole, R> zipWithPreview<Part2, R>(
    Preview<Whole, Part2> other,
    NonEmptySet<R> Function(NonEmptySet<Part> value1, Part2 value2) function,
  ) {
    return zipWith(other.asFoldSet(), (value1, value2) {
      return function(value1, value2.any);
    });
  }

  @override
  String toString() {
    return "FoldSet<$Whole, $Part>";
  }

  Preview<Whole, NonEmptySet<Part>> asPreview() {
    return Preview((whole) {
      return NonEmptySet.fromISet(get(whole));
    });
  }

  Getter<Whole, ISet<Part>> asGetter() {
    return Getter(get);
  }
}
