// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:collection/collection.dart';
import 'package:obmin/types/non_empty_list.dart';
import 'package:obmin/types/non_empty_map.dart';
import 'package:obmin/types/non_empty_set.dart';
import 'package:obmin/types/product.dart';

extension ListAsSetExtension<Element> on List<Element> {
  Set<Product<int, Element>> asSetOfProduct() {
    return mapIndexed(Product.new).toSet();
  }
}

extension NonEmptyListAsNonEmptySetExtension<Element> on NonEmptyList<Element> {
  NonEmptySet<Product<int, Element>> asSetOfProduct() {
    return NonEmptySet.fromSet(asList().asSetOfProduct()).force();
  }
}

extension SetOfProductAsListExtension<Element> on Set<Product<int, Element>> {
  List<Element> fromSetOfProductToList() {
    final List<Element> list = [];
    for (final product in this) {
      final index = product.value1;
      final value = product.value2;

      if (index >= list.length) {
        list.add(value);
      } else {
        list.insert(index, value);
      }
    }

    return list;
  }
}

extension NonEmptySetOfProductAsNonEmptyListExtension<Element> on NonEmptySet<Product<int, Element>> {
  NonEmptyList<Element> fromSetOfProductToList() {
    final List<Element> list = [];

    forEach((product) {
      final index = product.value1;
      final value = product.value2;

      if (index >= list.length) {
        list.add(value);
      } else {
        list.insert(index, value);
      }
    });

    return NonEmptyList.fromList(list).force();
  }
}

extension MapAsSetExtension<Key, Value> on Map<Key, Value> {
  Set<Product<Key, Value>> asSetOfProduct() {
    final Set<Product<Key, Value>> result = {};
    forEach((key, value) {
      result.add(Product(key, value));
    });

    return result;
  }
}

extension SetOfProductAsMapExtension<Key, Value> on Set<Product<Key, Value>> {
  Map<Key, Value> fromSetOfProductToMap() {
    final Map<Key, Value> map = {};
    for (final product in this) {
      map[product.value1] = product.value2;
    }

    return map;
  }
}

extension NonEmptyMapAsNonEmptySetExtension<Key, Value> on NonEmptyMap<Key, Value> {
  NonEmptySet<Product<Key, Value>> asSetOfProduct() {
    return NonEmptySet.fromSet(asMap().asSetOfProduct()).force();
  }
}

extension NonEmptySetOfProductAsNonEmptyMapExtension<Key, Value> on NonEmptySet<Product<Key, Value>> {
  NonEmptyMap<Key, Value> fromSetOfProductToMap() {
    final Map<Key, Value> map = {};

    forEach((product) {
      final key = product.value1;
      final value = product.value2;

      map[key] = value;
    });

    return NonEmptyMap.fromMap(map).force();
  }
}
