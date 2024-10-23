// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:obmin/fp/optional.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

@immutable
final class FoldSet<Whole, Part> {
  @useResult
  final ISet<Part> Function(Whole whole) get;

  const FoldSet(this.get);

  @useResult
  FoldSet<Whole, Sub> compose<Sub>(FoldSet<Part, Sub> other) {
    return FoldSet((whole) {
      return get(whole).expand(other.get).toISet();
    });
  }

  @useResult
  FoldSet<Whole, Part> composeWithEqv(Eqv<Part> other) {
    return compose(other.asFoldSet());
  }

  @useResult
  FoldSet<Whole, Sub> composeWithGetter<Sub>(Getter<Part, Sub> other) {
    return compose(other.asFoldSet());
  }

  @useResult
  FoldSet<Whole, Sub> composeWithPreview<Sub>(Preview<Part, Sub> other) {
    return compose(other.asFoldSet());
  }

  @useResult
  FoldSet<Whole, R> zipWith<Part2, R>(
    FoldSet<Whole, Part2> other,
    ISet<R> Function(ISet<Part> value1, ISet<Part2> value2) function,
  ) {
    return FoldSet((whole) {
      final set1 = get(whole);
      final set2 = other.get(whole);
      if (set1.isEmpty || set2.isEmpty) {
        const ISet.empty();
      }

      return function(set1, set2);
    });
  }

  @useResult
  FoldSet<Whole, R> zipWithEqv<R>(
    Eqv<Whole> other,
    ISet<R> Function(ISet<Part> value1, Whole value2) function,
  ) {
    return zipWith(other.asFoldSet(), (value1, value2) {
      return function(value1, value2.first);
    });
  }

  @useResult
  FoldSet<Whole, R> zipWithGetter<Part2, R>(
    Getter<Whole, Part2> other,
    ISet<R> Function(ISet<Part> value1, Part2 value2) function,
  ) {
    return zipWith(other.asFoldSet(), (value1, value2) {
      return function(value1, value2.first);
    });
  }

  @useResult
  FoldSet<Whole, R> zipWithPreview<Part2, R>(
    Preview<Whole, Part2> other,
    ISet<R> Function(ISet<Part> value1, Part2 value2) function,
  ) {
    return zipWith(other.asFoldSet(), (value1, value2) {
      return function(value1, value2.first);
    });
  }

  @useResult
  @override
  String toString() {
    return "FoldSet<$Whole, $Part>";
  }

  @useResult
  Preview<Whole, ISet<Part>> asPreview() {
    return Preview((whole) {
      final set = get(whole);
      if (set.isEmpty) {
        return const Optional.none();
      }
      return Optional.some(set);
    });
  }

  @useResult
  Getter<Whole, ISet<Part>> asGetter() {
    return Getter(get);
  }
}
