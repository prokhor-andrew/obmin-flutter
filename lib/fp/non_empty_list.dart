// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:obmin/fp/optional.dart';

@immutable
final class NonEmptyList<T> {
  final T head;
  final IList<T> tail;

  const NonEmptyList({
    required this.head,
    this.tail = const IList.empty(),
  });

  @useResult
  int get length => tail.length + 1;

  @useResult
  static Optional<NonEmptyList<T>> fromIList<T>(IList<T> list) {
    if (list.isEmpty) {
      return const Optional.none();
    }

    return Optional.some(NonEmptyList(head: list.first, tail: list.removeAt(0)));
  }

  @useResult
  IList<T> toIList() {
    return [head].lock.addAll(tail);
  }

  @useResult
  @override
  String toString() {
    return "NonEmptyList<$T> { head=$head, tail=$tail }";
  }

  @useResult
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NonEmptyList<T>) return false;

    return other.toIList() == toIList();
  }

  @useResult
  @override
  int get hashCode => toIList().hashCode;

  @useResult
  Optional<T> getOrNone(int index) {
    if (index < 0 || index >= length) {
      return const Optional.none();
    }

    if (index == 0) {
      return Optional.some(head);
    }

    return Optional.some(tail.get(index - 1));
  }

  @useResult
  Optional<NonEmptyList<T>> insertAt(int index, T element) {
    if (index < 0 || index > length) {
      return const Optional.none();
    }
    if (index == 0) {
      return Optional.some(NonEmptyList(head: element, tail: [head].lock.addAll(tail)));
    }

    return Optional.some(NonEmptyList(head: head, tail: tail.insert(index - 1, element)));
  }

  @useResult
  NonEmptyList<T> add(T element) {
    return NonEmptyList(head: head, tail: tail.add(element));
  }

  @useResult
  Optional<NonEmptyList<T>> removeAt(int index) {
    if (index < 0 || index >= length) {
      return Optional.some(this);
    }

    if (length == 1) {
      return const Optional.none();
    }

    return Optional.some(NonEmptyList(head: head, tail: tail.removeAt(index - 1)));
  }

  @useResult
  Optional<NonEmptyList<T>> replaceAt(int index, T element) {
    if (index < 0 || index >= length) {
      return const Optional.none();
    }

    if (index == 0) {
      return Optional.some(NonEmptyList(head: element, tail: tail));
    }

    return Optional.some(NonEmptyList(head: head, tail: tail.replace(index - 1, element)));
  }

  @useResult
  Optional<int> firstIndexWhere(bool Function(T element) predicate) {
    if (predicate(head)) {
      return Optional.some(0);
    }

    for (int i = 0; i < tail.length; i++) {
      final element = tail[i];
      if (predicate(element)) {
        return Optional.some(i + 1);
      }
    }

    return const Optional.none();
  }

  @useResult
  Optional<int> lastIndexWhere(bool Function(T element) predicate) {
    if (tail.isEmpty) {
      if (predicate(head)) {
        return Optional.some(0);
      } else {
        return const Optional.none();
      }
    }

    for (int i = tail.length - 1; i >= 0; i--) {
      final element = tail[i];
      if (predicate(element)) {
        return Optional.some(i + 1);
      }
    }

    return const Optional.none();
  }

  @useResult
  IList<int> allIndexesWhere(bool Function(T element) predicate) {
    IList<int> indexes = const IList.empty();

    if (predicate(head)) {
      indexes = indexes.add(0);
    }

    for (int i = 0; i < tail.length; i++) {
      if (predicate(tail[i])) {
        indexes = indexes.add(i + 1);
      }
    }

    return indexes;
  }

  @useResult
  bool contains(T element) {
    if (head == element) {
      return true;
    }

    return tail.contains(element);
  }

  Optional<NonEmptyList<T>> removeWhere(bool Function(T value) predicate) {
    final result = toIList().removeWhere(predicate);
    return NonEmptyList.fromIList(result);
  }

  @useResult
  NonEmptyList<T> get reversed => NonEmptyList.fromIList(toIList().reversed).force();

  @useResult
  R foldLeftIndexed<R>(R initial, R Function(R cur, int index, T element) function) {
    R result = initial;
    final list = toIList();
    for (int i = 0; i < length; i++) {
      final element = list[i];
      result = function(result, i, element);
    }

    return result;
  }

  @useResult
  R foldRightIndexed<R>(R initial, R Function(R cur, int index, T element) function) {
    R result = initial;
    final list = toIList();
    for (int i = length - 1; i >= 0; i--) {
      final element = list[i];
      result = function(result, i, element);
    }

    return result;
  }

  @useResult
  R foldLeft<R>(R initial, R Function(R cur, T element) function) {
    return foldLeftIndexed(initial, (cur, _, element) => function(cur, element));
  }

  @useResult
  R foldRight<R>(R initial, R Function(R cur, T element) function) {
    return foldRightIndexed(initial, (cur, _, element) => function(cur, element));
  }

  @useResult
  NonEmptyList<R> mapList<R>(R Function(T value) function) {
    return NonEmptyList(head: function(head), tail: tail.mapList(function));
  }

  @useResult
  NonEmptyList<R> mapListToLazy<R>(R Function() function) {
    return mapList((_) => function());
  }

  @useResult
  NonEmptyList<R> mapListTo<R>(R value) {
    return mapListToLazy(() => value);
  }

  @useResult
  NonEmptyList<R> ap<R>(NonEmptyList<R Function(T)> other) {
    return NonEmptyList.fromIList(toIList().bind((value) => other.mapList((f) => f(value)).toIList())).force();
  }

  @useResult
  NonEmptyList<R> bind<R>(NonEmptyList<R> Function(T value) function) {
    return NonEmptyList.fromIList(toIList().bind((val) => function(val).toIList())).force();
  }

  @useResult
  NonEmptyList<R> zipWith<T2, R>(
    NonEmptyList<T2> other,
    R Function(T value1, T2 value2) function,
  ) {
    final curried = (T val1) => (T2 val2) => function(val1, val2);
    return other.ap(mapList(curried));
  }
}

extension OptionalOfNonEmptyListToIListExtension<Element> on Optional<NonEmptyList<Element>> {
  @useResult
  IList<Element> toIList() {
    return fold(
      (value) => value.toIList(),
      () => const IList.empty(),
    );
  }
}

extension IListExtension<T> on IList<T> {
  @useResult
  IList<R> mapList<R>(R Function(T value) function) {
    return map(function).toIList();
  }

  @useResult
  IList<R> mapListToLazy<R>(R Function() function) {
    return mapList((_) => function());
  }

  @useResult
  IList<R> mapListTo<R>(R value) {
    return mapListToLazy(() => value);
  }

  @useResult
  IList<R> ap<R>(IList<R Function(T)> other) {
    return expand((value) => other.map((f) => f(value))).toIList();
  }

  @useResult
  IList<R> bind<R>(IList<R> Function(T value) function) {
    return expand(function).toIList();
  }

  @useResult
  IList<R> zipWith<T2, R>(
    IList<T2> other,
    R Function(T value1, T2 value2) function,
  ) {
    final curried = (T val1) => (T2 val2) => function(val1, val2);
    return other.ap(mapList(curried));
  }
}
