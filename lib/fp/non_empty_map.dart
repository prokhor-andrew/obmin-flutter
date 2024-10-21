// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:obmin/fp/non_empty_set.dart';
import 'package:obmin/fp/optional.dart';
import 'package:obmin/fp/product.dart';

@immutable
final class NonEmptyMap<Key, Value> {
  final MapEntry<Key, Value> any;
  final IMap<Key, Value> rest;

  const NonEmptyMap({
    required this.any,
    this.rest = const IMap.empty(),
  });

  @useResult
  static Optional<NonEmptyMap<Key, Value>> fromIMap<Key, Value>(IMap<Key, Value> map) {
    if (map.isEmpty) {
      return const Optional.none();
    }

    final iterator = map.entries.iterator;
    iterator.moveNext();
    final extractedEntry = iterator.current;

    final remainingMap = map.remove(extractedEntry.key);

    return Optional.some(NonEmptyMap(any: extractedEntry, rest: remainingMap));
  }

  @useResult
  IMap<Key, Value> toIMap() {
    return rest.add(any.key, any.value);
  }

  @useResult
  @override
  String toString() {
    return "NonEmptyMap<$Key, $Value> { any=$any, rest=$rest }";
  }

  @useResult
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NonEmptyMap<Key, Value>) return false;

    return toIMap() == other.toIMap();
  }

  @override
  @useResult
  int get hashCode => toIMap().hashCode;

  @useResult
  int get length => rest.length + 1;

  @useResult
  NonEmptyMap<Key, Value> add(Key key, Value value) {
    return NonEmptyMap(any: any, rest: rest.add(key, value));
  }

  @useResult
  Optional<NonEmptyMap<Key, Value>> remove(Key key) {
    return NonEmptyMap.fromIMap(toIMap().remove(key));
  }

  @useResult
  bool containsKey(Key key) {
    if (any.key == key) {
      return true;
    }

    return rest.containsKey(key);
  }

  @useResult
  bool containsValue(Value value) {
    if (any.value == value) {
      return true;
    }

    return rest.containsValue(value);
  }

  @useResult
  bool contains(Key key, Value value) {
    if (any.key == key && any.value == value) {
      return true;
    }

    return rest.contains(key, value);
  }

  @useResult
  ISet<Key> keysWhere(bool Function(Value value) predicate) {
    ISet<Key> keys = const ISet.empty();

    if (predicate(any.value)) {
      keys = keys.add(any.key);
    }

    rest.forEach((key, value) {
      if (predicate(value)) {
        keys = keys.add(key);
      }
    });

    return keys;
  }
}

extension OptionalOfNonEmptyMapToISetExtension<Key, Value> on Optional<NonEmptyMap<Key, Value>> {
  @useResult
  IMap<Key, Value> toIMap() {
    return fold(
      (value) => value.toIMap(),
      () => const IMap.empty(),
    );
  }
}

extension NonEmptySetOfProductsToNonEmptyMapExtension<Key, Value> on NonEmptySet<Product<Key, Value>> {
  @useResult
  NonEmptyMap<Key, Value> fromSetOfProductToMap() {
    return NonEmptyMap.fromIMap<Key, Value>(fold(const IMap.empty(), (acc, product) {
      final key = product.left;
      final element = product.right;

      return acc.add(key, element);
    })).force();
  }
}
