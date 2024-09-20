// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:collection/collection.dart';
import 'package:obmin/types/non_empty_list.dart';
import 'package:obmin/types/optional.dart';
import 'package:obmin/utils/set_plus.dart';

final class NonEmptySet<T> {
  final T any;
  final Set<T> rest;

  const NonEmptySet({
    required this.any,
    required this.rest,
  });

  static Optional<NonEmptySet<T>> fromSet<T>(Set<T> set) {
    if (set.isEmpty) {
      return Optional.none();
    }
    final list = set.toList();
    return Optional.some(
      NonEmptySet(
        any: list.first,
        rest: list.sublist(1).toSet(),
      ),
    );
  }

  Set<T> asSet() {
    return rest.plus(any);
  }

  NonEmptySet<R> map<R>(R Function(T value) function) {
    final mappedAny = function(any);
    final mappedRest = rest.map(function).toSet();

    return NonEmptySet(
      any: mappedAny,
      rest: mappedRest,
    );
  }

  NonEmptySet<R> bind<R>(NonEmptySet<R> Function(T value) function) {
    final mappedAnyNonEmptySet = function(any);

    final Set<R> resultRest = mappedAnyNonEmptySet.rest.toSet();

    for (final item in rest.toSet()) {
      resultRest.addAll(function(item).asSet());
    }

    return NonEmptySet(
      any: mappedAnyNonEmptySet.any,
      rest: resultRest,
    );
  }

  R fold<R>(R initialValue, R Function(R acc, T value) function) {
    R result = function(initialValue, any);
    for (final item in rest.toSet()) {
      result = function(result, item);
    }
    return result;
  }

  Optional<NonEmptySet<T>> filter(bool Function(T value) predicate) {
    final filteredRest = rest.where(predicate).toSet();
    if (predicate(any)) {
      return Optional.some(NonEmptySet(any: any, rest: filteredRest));
    } else if (filteredRest.isNotEmpty) {
      final list = filteredRest.toList();
      return Optional.some(NonEmptySet(any: list.first, rest: list.skip(1).toSet()));
    }
    return Optional.none();
  }

  void forEach(void Function(T value) action) {
    action(any);
    rest.toSet().forEach(action);
  }

  NonEmptySet<T> plus(T value) {
    return NonEmptySet(any: any, rest: {value, ...rest.toSet()});
  }

  NonEmptySet<T> plusMultiple(NonEmptySet<T> other) {
    return NonEmptySet(any: any, rest: {other.any, ...other.rest.toSet(), ...rest.toSet()});
  }

  int get length => rest.length + 1;

  Optional<T> findWhere(bool Function(T value) predicate) {
    if (predicate(any)) {
      return Optional.some(any);
    }

    for (final element in rest.toSet()) {
      if (predicate(element)) {
        return Optional.some(element);
      }
    }

    return Optional.none();
  }

  Set<T> minus(T value) {
    if (any == value) {
      return rest.toSet();
    }

    final copy = rest.toSet();
    copy.remove(value);

    return {any, ...copy};
  }

  Set<T> minusWhere(bool Function(T value) predicate) {
    if (predicate(any)) {
      return rest.toSet();
    }

    final result = {any};

    for (final element in rest.toSet()) {
      if (!predicate(element)) {
        result.add(element);
      }
    }

    return result;
  }

  bool contains(T value) {
    return containsWhere((iValue) => iValue == value);
  }

  bool containsWhere(bool Function(T value) predicate) {
    return findWhere(predicate).isSome;
  }

  NonEmptyList<T> asNonEmptyList() {
    return NonEmptyList(
      head: any,
      tail: rest.toList(),
    );
  }

  @override
  String toString() {
    return "NonEmptySet<$T> { any=$any, rest=$rest }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NonEmptySet<T>) return false;
    final setEquality = SetEquality<T>();
    return any == other.any && setEquality.equals(rest, other.rest);
  }

  @override
  int get hashCode {
    final setEquality = SetEquality<T>();
    return Object.hash(any, setEquality.hash(rest));
  }
}
