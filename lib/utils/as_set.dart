// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:collection/collection.dart';
import 'package:obmin/types/product.dart';

extension ListAsSetExtension<Element> on List<Element> {
  Set<Product<int, Element>> asSet() {
    return mapIndexed(Product.new).toSet();
  }
}

extension MapAsSetExtension<Key, Value> on Map<Key, Value> {
  Set<Product<Key, Value>> asSet() {
    final Set<Product<Key, Value>> result = {};
    forEach((key, value) {
      result.add(Product(key, value));
    });

    return result;
  }
}
