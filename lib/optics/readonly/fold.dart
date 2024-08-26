// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/types/non_empty_iterable.dart';

final class Fold<Whole, Part> {
  final Iterable<Part> Function(Whole whole) get;

  const Fold(this.get);

  Fold<Whole, Sub> compose<Sub>(Fold<Part, Sub> other) {
    return Fold((whole) {
      return get(whole).expand(other.get);
    });
  }

  Fold<Whole, Part> composeWithEqv(Eqv<Part> other) {
    return compose(other.asFold());
  }

  Fold<Whole, Sub> composeWithGetter<Sub>(Getter<Part, Sub> other) {
    return compose(other.asFold());
  }

  Fold<Whole, Sub> composeWithPreview<Sub>(Preview<Part, Sub> other) {
    return compose(other.asFold());
  }

  Fold<Whole, R> zipWith<Part2, R>(
    Fold<Whole, Part2> other,
    NonEmptyIterable<R> Function(NonEmptyIterable<Part> value1, NonEmptyIterable<Part2> value2) function,
  ) {
    return Fold((whole) {
      return NonEmptyIterable.fromIterable(get(whole)).bind((value1) {
        return NonEmptyIterable.fromIterable(other.get(whole)).map((value2) {
          return (value1, value2);
        });
      }).map((tuple) {
        final value1 = tuple.$1;
        final value2 = tuple.$2;
        return function(value1, value2).asIterable();
      }).valueOr([]);
    });
  }

  Fold<Whole, R> zipWithEqv<R>(
    Eqv<Whole> other,
    NonEmptyIterable<R> Function(NonEmptyIterable<Part> value1, Whole value2) function,
  ) {
    return zipWith(other.asFold(), (value1, value2) {
      return function(value1, value2.head);
    });
  }

  Fold<Whole, R> zipWithGetter<Part2, R>(
    Getter<Whole, Part2> other,
    NonEmptyIterable<R> Function(NonEmptyIterable<Part> value1, Part2 value2) function,
  ) {
    return zipWith(other.asFold(), (value1, value2) {
      return function(value1, value2.head);
    });
  }

  Fold<Whole, R> zipWithPreview<Part2, R>(
    Preview<Whole, Part2> other,
    NonEmptyIterable<R> Function(NonEmptyIterable<Part> value1, Part2 value2) function,
  ) {
    return zipWith(other.asFold(), (value1, value2) {
      return function(value1, value2.head);
    });
  }

  @override
  String toString() {
    return "Fold<$Whole, $Part>";
  }

  Preview<Whole, NonEmptyIterable<Part>> asPreview() {
    return Preview((whole) {
      return NonEmptyIterable.fromIterable(get(whole));
    });
  }

  Getter<Whole, Iterable<Part>> asGetter() {
    return Getter(get);
  }
}
