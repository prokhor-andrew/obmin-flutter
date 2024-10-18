// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:obmin/fp/optional.dart';

@immutable
final class NonEmptySet<T> {
  final T any;
  final ISet<T> rest;

  const NonEmptySet({
    required this.any,
    this.rest = const ISet.empty(),
  });

  @useResult
  static Optional<NonEmptySet<T>> fromISet<T>(ISet<T> set) {
    if (set.isEmpty) {
      return const Optional.none();
    }
    final list = set.toIList();
    return Optional.some(
      NonEmptySet(
        any: list.first,
        rest: list.removeAt(0).toISet(),
      ),
    );
  }

  @useResult
  ISet<T> toISet() {
    return rest.add(any);
  }

  @useResult
  NonEmptySet<R> map<R>(R Function(T value) function) {
    final mappedAny = function(any);
    final mappedRest = rest.map(function).toISet();

    return NonEmptySet(
      any: mappedAny,
      rest: mappedRest,
    );
  }

  @useResult
  NonEmptySet<R> mapToLazy<R>(R Function() function) {
    return map((_) => function());
  }

  @useResult
  NonEmptySet<R> mapTo<R>(R value) {
    return mapToLazy(() => value);
  }

  @useResult
  NonEmptySet<R> bind<R>(NonEmptySet<R> Function(T value) function) {
    final mappedAnyNonEmptySet = function(any);

    ISet<R> resultRest = mappedAnyNonEmptySet.rest;

    for (final item in rest) {
      resultRest = resultRest.addAll(function(item).toISet());
    }

    return NonEmptySet(
      any: mappedAnyNonEmptySet.any,
      rest: resultRest,
    );
  }

  @useResult
  R fold<R>(R initialValue, R Function(R acc, T value) function) {
    R result = function(initialValue, any);
    for (final item in rest) {
      result = function(result, item);
    }
    return result;
  }

  void forEach(void Function(T value) action) {
    action(any);
    rest.forEach(action);
  }

  @useResult
  Optional<NonEmptySet<T>> removeWhere(bool Function(T value) predicate) {
    final filteredRest = rest.removeWhere(predicate);
    if (!predicate(any)) {
      return Optional.some(NonEmptySet(any: any, rest: filteredRest));
    }

    if (filteredRest.isNotEmpty) {
      final list = filteredRest.toIList();

      return Optional.some(
        NonEmptySet(
          any: list.first,
          rest: list.removeAt(0).toISet(),
        ),
      );
    }

    return const Optional.none();
  }

  @useResult
  Optional<NonEmptySet<T>> remove(T value) {
    return NonEmptySet.fromISet(toISet().remove(value));
  }

  @useResult
  NonEmptySet<T> add(T value) {
    return NonEmptySet(any: any, rest: rest.add(value));
  }

  @useResult
  NonEmptySet<T> addAll(NonEmptySet<T> other) {
    return NonEmptySet(any: any, rest: rest.addAll(other.toISet()));
  }

  @useResult
  int get length => rest.length + 1;

  @useResult
  Optional<T> findWhere(bool Function(T value) predicate) {
    if (predicate(any)) {
      return Optional.some(any);
    }

    for (final element in rest) {
      if (predicate(element)) {
        return Optional.some(element);
      }
    }

    return const Optional.none();
  }

  @useResult
  NonEmptySet<T> replace(T withElement, T forElement) {
    return NonEmptySet.fromISet(toISet().remove(forElement).add(withElement)).force();
  }

  @useResult
  NonEmptySet<T> replaceWhere(T withElement, bool Function(T element) predicate) {
    return findWhere(predicate).map((forElement) {
      return replace(withElement, forElement);
    }).valueOr(this);
  }

  @useResult
  bool contains(T value) {
    return toISet().contains(value);
  }

  @useResult
  bool containsWhere(bool Function(T value) predicate) {
    return findWhere(predicate).isSome;
  }

  @useResult
  @override
  String toString() {
    return "NonEmptySet<$T> { any=$any, rest=$rest }";
  }

  @useResult
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NonEmptySet<T>) return false;

    return toISet() == other.toISet();
  }

  @useResult
  @override
  int get hashCode {
    return toISet().hashCode;
  }
}

extension OptionalOfNonEmptySetToISetExtension<Element> on Optional<NonEmptySet<Element>> {
  @useResult
  ISet<Element> toISet() {
    return fold(
      (value) => value.toISet(),
      () => const ISet.empty(),
    );
  }
}
