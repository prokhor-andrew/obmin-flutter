// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/non_empty_set.dart';
import 'package:obmin/types/optional.dart';
import 'package:obmin/types/product.dart';

final class NonEmptyMap<K, T> {
  final MapEntry<K, T> any;
  final IMap<K, T> rest;

  const NonEmptyMap({
    required this.any,
    required this.rest,
  });

  static Optional<NonEmptyMap<K, T>> fromIMap<K, T>(IMap<K, T> map) {

    final iterator = map.entries.iterator;
    if (iterator.moveNext()) {
      final any = iterator.current;
      final rest = Map.of(map)..remove(any.key);

      return Optional.some(
        NonEmptyMap(any: any, rest: rest),
      );
    }

    return Optional.none();
  }

  IMap<K, T> toIMap() {
    return rest.add(any.key, any.value);
  }

  NonEmptyMap<K, R> zipWith<R, U>(
    NonEmptyMap<K, U> other,
    R Function(K key, Either<Product<T, U>, Either<T, U>>) combine,
  ) {

    final combinedKeys = {...rest.keys, ...other.rest.keys, any.key, other.any.key}.lock;

    IMap<K, R> result = const IMap.empty();

    for (K key in combinedKeys) {
      final bool hasT = rest.containsKey(key) || key == any.key;
      final bool hasU = other.rest.containsKey(key) || key == other.any.key;

      if (hasT && hasU) {
        final tValue = key == any.key ? any.value : rest[key]!;
        final uValue = key == other.any.key ? other.any.value : other.rest[key]!;
        result[key] = combine(key, Either.left(Product(tValue, uValue)));
      } else if (hasT) {
        final tValue = key == any.key ? any.value : rest[key]!;
        result[key] = combine(key, Either.right(Either.left(tValue)));
      } else {
        final uValue = key == other.any.key ? other.any.value : other.rest[key]!;
        result[key] = combine(key, Either.right(Either.right(uValue)));
      }
    }

    final firstEntry = result.entries.first;
    return NonEmptyMap<K, R>(
      any: MapEntry(firstEntry.key, firstEntry.value),
      rest: Map.fromEntries(result.entries.skip(1)),
    );
  }

  NonEmptyMap<K, R> mapKeyed<R>(R Function(K key, T value) function) {
    final mappedAny = MapEntry(any.key, function(any.key, any.value));
    final mappedRest = rest.map((key, value) {
      return MapEntry(key, function(key, value));
    });
    return NonEmptyMap(
      any: mappedAny,
      rest: mappedRest,
    );
  }

  NonEmptyMap<K, R> map<R>(R Function(T value) function) {
    return mapKeyed((_, value) => function(value));
  }

  NonEmptyMap<K, R> bindKeyed<R>(NonEmptyMap<K, R> Function(K key, T value) function) {
    final NonEmptyMap<K, R> first = function(any.key, any.value);

    IMap<K, R> resultMap = first.asMap();

    for (final entry in rest.entries) {
      final NonEmptyMap<K, R> mapped = function(entry.key, entry.value);
      resultMap = resultMap.addAll(mapped.asMap());
    }

    final iterator = resultMap.entries.iterator;
    iterator.moveNext();
    final MapEntry<K, R> newAny = iterator.current;
    resultMap = resultMap.remove(newAny.key);

    return NonEmptyMap(any: newAny, rest: resultMap);
  }

  NonEmptyMap<K, R> bind<R>(NonEmptyMap<K, R> Function(T value) function) {
    return bindKeyed((_, value) => function(value));
  }

  R foldKeyed<R>(R initialValue, R Function(R acc, K key, T value) function) {
    R accumulator = function(initialValue, any.key, any.value);

    rest.forEach((key, value) {
      accumulator = function(accumulator, key, value);
    });

    return accumulator;
  }

  R fold<R>(R initialValue, R Function(R acc, T value) function) {
    return foldKeyed(initialValue, (acc, _, value) => function(acc, value));
  }

  Optional<NonEmptyMap<K, T>> filterKeyed(bool Function(K key, T value) predicate) {
    if (!predicate(any.key, any.value)) {
      final filteredRest = rest.entries.where((entry) => predicate(entry.key, entry.value)).toList();

      if (filteredRest.isEmpty) {
        return Optional.none();
      } else {
        final newAny = filteredRest.first;
        final newRest = Map<K, T>.fromEntries(filteredRest.skip(1));
        return Optional.some(NonEmptyMap(any: newAny, rest: newRest));
      }
    } else {
      final filteredRest = rest.entries.where((entry) => predicate(entry.key, entry.value)).toList();
      final newRest = Map<K, T>.fromEntries(filteredRest);

      return Optional.some(NonEmptyMap(any: any, rest: newRest));
    }
  }

  Optional<NonEmptyMap<K, T>> filter(bool Function(T value) predicate) {
    return filterKeyed((_, value) => predicate(value));
  }

  void forEachKeyed(void Function(K key, T value) action) {
    action(any.key, any.value);
    rest.entries.toList().forEach((entry) => action(entry.key, entry.value));
  }

  void forEach(void Function(T value) action) {
    forEachKeyed((_, value) => action(value));
  }

  Optional<T> getOrNone(K key) {
    if (any.key == key) {
      return Optional.some(any.value);
    }

    if (rest.containsKey(key)) {
      return Optional.some(rest[key]!);
    }

    return Optional.none();
  }

  NonEmptyMap<K, T> plus(K key, T value) {
    if (any.key == key) {
      return NonEmptyMap(any: MapEntry(key, value), rest: rest);
    } else if (rest.containsKey(key)) {
      final updatedRest = Map<K, T>.of(rest);
      updatedRest[key] = value;
      return NonEmptyMap(any: any, rest: updatedRest);
    } else {
      final updatedRest = Map<K, T>.of(rest);
      updatedRest[key] = value;
      return NonEmptyMap(any: any, rest: updatedRest);
    }
  }

  NonEmptyMap<K, T> plusMultiple(Map<K, T> map) {
    final updatedRest = Map<K, T>.of(rest);

    bool anyUpdated = false;
    MapEntry<K, T>? newAny;

    map.forEach((key, value) {
      if (key == any.key) {
        newAny = MapEntry(key, value);
        anyUpdated = true;
      } else {
        updatedRest[key] = value;
      }
    });

    return NonEmptyMap(
      any: anyUpdated ? newAny! : any,
      rest: updatedRest,
    );
  }

  Optional<NonEmptyMap<K, T>> minus(K key) {
    if (key == any.key) {
      if (rest.isEmpty) {
        return Optional.none();
      } else {
        final iterator = rest.entries.iterator;
        iterator.moveNext();
        final newAny = iterator.current;
        final newRest = Map<K, T>.of(rest)..remove(newAny.key);

        return Optional.some(NonEmptyMap(any: newAny, rest: newRest));
      }
    } else if (rest.containsKey(key)) {
      final updatedRest = Map<K, T>.of(rest)..remove(key);
      return Optional.some(NonEmptyMap(any: any, rest: updatedRest));
    }

    return Optional.some(this);
  }

  Optional<NonEmptyMap<K, T>> minusMultiple(Set<K> keys) {
    bool anyRemoved = keys.contains(any.key);

    final updatedRest = Map<K, T>.of(rest)..removeWhere((key, _) => keys.contains(key));

    if (anyRemoved) {
      if (updatedRest.isEmpty) {
        return Optional.none();
      } else {
        final iterator = updatedRest.entries.iterator;
        iterator.moveNext();
        final newAny = iterator.current;
        updatedRest.remove(newAny.key);

        return Optional.some(NonEmptyMap(any: newAny, rest: updatedRest));
      }
    } else {
      return Optional.some(NonEmptyMap(any: any, rest: updatedRest));
    }
  }

  NonEmptyMap<K, T> swap(K key1, K key2) {
    if (key1 == key2) {
      return this;
    }

    T? value1;
    T? value2;

    bool key1Exists = false;
    bool key2Exists = false;

    if (any.key == key1) {
      value1 = any.value;
      key1Exists = true;
    } else if (rest.containsKey(key1)) {
      value1 = rest[key1];
      key1Exists = true;
    }

    if (any.key == key2) {
      value2 = any.value;
      key2Exists = true;
    } else if (rest.containsKey(key2)) {
      value2 = rest[key2];
      key2Exists = true;
    }

    if (!key1Exists || !key2Exists) {
      return this;
    }

    final updatedRest = Map<K, T>.of(rest);

    MapEntry<K, T>? newAny = any;

    if (any.key == key1) {
      newAny = MapEntry(key1, value2!);
    } else if (any.key == key2) {
      newAny = MapEntry(key2, value1!);
    }

    if (rest.containsKey(key1)) {
      updatedRest[key1] = value2!;
    }

    if (rest.containsKey(key2)) {
      updatedRest[key2] = value1!;
    }

    return NonEmptyMap(any: newAny, rest: updatedRest);
  }

  int get length => rest.length + 1;

  Optional<T> findWhereKeyed(bool Function(K key, T value) predicate) {
    if (predicate(any.key, any.value)) {
      return Optional.some(any.value);
    }

    for (final entry in rest.entries) {
      if (predicate(entry.key, entry.value)) {
        return Optional.some(entry.value);
      }
    }

    return Optional.none();
  }

  Optional<T> findWhere(bool Function(T value) predicate) {
    return findWhereKeyed((_, value) => predicate(value));
  }

  bool contains(T value) {
    return containsWhere((iValue) => iValue == value);
  }

  bool containsWhereKeyed(bool Function(K key, T value) predicate) {
    return findWhereKeyed((key, value) => predicate(key, value)).isSome;
  }

  bool containsWhere(bool Function(T value) predicate) {
    return containsWhereKeyed((_, value) => predicate(value));
  }

  NonEmptySet<Product<K, T>> asNonEmptySet() {
    final copy = Map.from(rest);

    final Set<Product<K, T>> restSet = {};
    copy.forEach((key, value) {
      restSet.add(Product(key, value));
    });

    return NonEmptySet(
      any: Product(any.key, any.value),
      rest: restSet,
    );
  }

  @override
  String toString() {
    return "NonEmptyMap<$K, $T> { any=$any, rest=$rest }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! NonEmptyMap<K, T>) return false;

    final mapEquality = const DeepCollectionEquality();

    return any == other.any && mapEquality.equals(rest, other.rest);
  }

  @override
  int get hashCode {
    final mapEquality = const DeepCollectionEquality();
    return any.hashCode ^ mapEquality.hash(rest);
  }
}

extension OptionalOfNonEmptyMapToIMapExtension<Key, Value> on Optional<NonEmptyMap<Key, Value>> {
  IMap<Key, Value> toIMap() {
    return fold(
      (value) => value.toIMap(),
      () => const IMap.empty(),
    );
  }
}
