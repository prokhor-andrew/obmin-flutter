// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:obmin/fp/non_empty_set.dart';
import 'package:obmin/fp/optional.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';

@immutable
final class Preview<Whole, Part> {
  @useResult
  final Optional<Part> Function(Whole whole) get;

  const Preview(this.get);

  @useResult
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

  @useResult
  Preview<Whole, R> zipWithEqv<R>(
    Eqv<Whole> other,
    R Function(Part value1, Whole value2) function,
  ) {
    return zipWith(other.asPreview(), function);
  }

  @useResult
  Preview<Whole, R> zipWithGetter<Part2, R>(
    Getter<Whole, Part2> other,
    R Function(Part value1, Part2 value2) function,
  ) {
    return zipWith(other.asPreview(), function);
  }

  @useResult
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

  @useResult
  Preview<Whole, Sub> compose<Sub>(Preview<Part, Sub> other) {
    return Preview((whole) {
      return get(whole).bind(other.get);
    });
  }

  @useResult
  Preview<Whole, Part> composeWithEqv(Eqv<Part> other) {
    return compose(other.asPreview());
  }

  @useResult
  Preview<Whole, Sub> composeWithGetter<Sub>(Getter<Part, Sub> other) {
    return compose(other.asPreview());
  }

  @useResult
  FoldSet<Whole, Sub> composeWithFoldSet<Sub>(FoldSet<Part, Sub> other) {
    return asFoldSet().compose(other);
  }

  @useResult
  @override
  String toString() {
    return "Preview<$Whole, $Part>";
  }

  @useResult
  Getter<Whole, Optional<Part>> asGetter() {
    return Getter(get);
  }

  @useResult
  FoldSet<Whole, Part> asFoldSet() {
    return FoldSet((whole) {
      return get(whole).map((value) => {value}.lock).valueOr(const ISet.empty());
    });
  }
}
