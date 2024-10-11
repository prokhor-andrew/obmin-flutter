// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:collection/collection.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/types/non_empty_list.dart';
import 'package:obmin/types/product.dart';

final class FoldList<Whole, Part> {
  final List<Part> Function(Whole whole) get;

  const FoldList(this.get);

  FoldList<Whole, Sub> compose<Sub>(FoldList<Part, Sub> other) {
    return FoldList((whole) {
      return get(whole).expand(other.get).toList();
    });
  }

  FoldList<Whole, Part> composeWithEqv(Eqv<Part> other) {
    return compose(other.asFoldList());
  }

  FoldList<Whole, Sub> composeWithGetter<Sub>(Getter<Part, Sub> other) {
    return compose(other.asFoldList());
  }

  FoldList<Whole, Sub> composeWithPreview<Sub>(Preview<Part, Sub> other) {
    return compose(other.asFoldList());
  }

  FoldList<Whole, R> zipWith<Part2, R>(
    FoldList<Whole, Part2> other,
    NonEmptyList<R> Function(NonEmptyList<Part> value1, NonEmptyList<Part2> value2) function,
  ) {
    return FoldList((whole) {
      return NonEmptyList.fromList(get(whole)).bind((value1) {
        return NonEmptyList.fromList(other.get(whole)).map((value2) {
          return (value1, value2);
        });
      }).map((tuple) {
        final value1 = tuple.$1;
        final value2 = tuple.$2;
        return function(value1, value2).asList();
      }).valueOr([]);
    });
  }

  FoldList<Whole, R> zipWithEqv<R>(
    Eqv<Whole> other,
    NonEmptyList<R> Function(NonEmptyList<Part> value1, Whole value2) function,
  ) {
    return zipWith(other.asFoldList(), (value1, value2) {
      return function(value1, value2.head);
    });
  }

  FoldList<Whole, R> zipWithGetter<Part2, R>(
    Getter<Whole, Part2> other,
    NonEmptyList<R> Function(NonEmptyList<Part> value1, Part2 value2) function,
  ) {
    return zipWith(other.asFoldList(), (value1, value2) {
      return function(value1, value2.head);
    });
  }

  FoldList<Whole, R> zipWithPreview<Part2, R>(
    Preview<Whole, Part2> other,
    NonEmptyList<R> Function(NonEmptyList<Part> value1, Part2 value2) function,
  ) {
    return zipWith(other.asFoldList(), (value1, value2) {
      return function(value1, value2.head);
    });
  }

  @override
  String toString() {
    return "FoldList<$Whole, $Part>";
  }

  Preview<Whole, NonEmptyList<Part>> asPreview() {
    return Preview((whole) {
      return NonEmptyList.fromList(get(whole));
    });
  }

  Getter<Whole, List<Part>> asGetter() {
    return Getter(get);
  }

  FoldSet<Whole, Product<int, Part>> asFoldSet() {
    return FoldSet((whole) {
      return get(whole).mapIndexed(Product.new).toSet();
    });
  }
}
