// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/fp/non_empty_list.dart';
import 'package:obmin/fp/non_empty_set.dart';
import 'package:obmin/fp/product.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

extension NonEmptyListOpticsEqvExtension<T> on Eqv<NonEmptyList<T>> {
  Getter<NonEmptyList<T>, NonEmptySet<Product<int, T>>> get asNonEmptySetOfProduct => asGetter().asNonEmptySetOfProduct;
}

extension ListOpticsGetterExtension<Whole, T> on Getter<Whole, NonEmptyList<T>> {
  Getter<Whole, NonEmptySet<Product<int, T>>> get asNonEmptySetOfProduct => compose(Getter((whole) {
        return NonEmptySet.fromISet(whole.toIList().toISetOfProducts()).force();
      }));
}

extension ListOpticsPreviewExtension<Whole, T> on Preview<Whole, NonEmptyList<T>> {
  Preview<Whole, NonEmptySet<Product<int, T>>> get asNonEmptySetOfProduct => composeWithGetter(Getter((whole) {
        return NonEmptySet.fromISet(whole.toIList().toISetOfProducts()).force();
      }));
}

extension ListOpticsFoldSetExtension<Whole, T> on FoldSet<Whole, NonEmptyList<T>> {
  FoldSet<Whole, NonEmptySet<Product<int, T>>> get asNonEmptySetOfProduct => composeWithGetter(Getter((whole) {
        return NonEmptySet.fromISet(whole.toIList().toISetOfProducts()).force();
      }));
}

extension ListOpticsMutatorExtension<Whole, T> on Mutator<Whole, NonEmptyList<T>> {
  Mutator<Whole, NonEmptySet<Product<int, T>>> get asNonEmptySetOfProduct => compose(Mutator.iso(Getter((whole) {
        return NonEmptySet.fromISet(whole.toIList().toISetOfProducts()).force();
      }), Getter((part) {
        return part.fromSetOfProductToList();
      })));
}
