// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/fp/non_empty_map.dart';
import 'package:obmin/fp/non_empty_set.dart';
import 'package:obmin/fp/product.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

extension NonEmptyMapOpticsEqvExtension<Key, Value> on Eqv<NonEmptyMap<Key, Value>> {
  Getter<NonEmptyMap<Key, Value>, NonEmptySet<Product<Key, Value>>> get asNonEmptySetOfProduct => asGetter().asNonEmptySetOfProduct;
}

extension ListOpticsGetterExtension<Whole, Key, Value> on Getter<Whole, NonEmptyMap<Key, Value>> {
  Getter<Whole, NonEmptySet<Product<Key, Value>>> get asNonEmptySetOfProduct => compose(Getter((whole) {
        return NonEmptySet.fromISet(whole.toIMap().toISetOfProducts()).force();
      }));
}

extension ListOpticsPreviewExtension<Whole, Key, Value> on Preview<Whole, NonEmptyMap<Key, Value>> {
  Preview<Whole, NonEmptySet<Product<Key, Value>>> get asNonEmptySetOfProduct => composeWithGetter(Getter((whole) {
        return NonEmptySet.fromISet(whole.toIMap().toISetOfProducts()).force();
      }));
}

extension ListOpticsFoldSetExtension<Whole, Key, Value> on FoldSet<Whole, NonEmptyMap<Key, Value>> {
  FoldSet<Whole, NonEmptySet<Product<Key, Value>>> get asNonEmptySetOfProduct => composeWithGetter(Getter((whole) {
        return NonEmptySet.fromISet(whole.toIMap().toISetOfProducts()).force();
      }));
}

extension ListOpticsMutatorExtension<Whole, Key, Value> on Mutator<Whole, NonEmptyMap<Key, Value>> {
  Mutator<Whole, NonEmptySet<Product<Key, Value>>> get asNonEmptySetOfProduct => compose(Mutator.iso(Getter((whole) {
        return NonEmptySet.fromISet(whole.toIMap().toISetOfProducts()).force();
      }), Getter((part) {
        return part.fromSetOfProductToMap();
      })));
}
