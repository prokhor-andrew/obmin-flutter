// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/fp/non_empty_set.dart';
import 'package:obmin/fp/optional.dart';
import 'package:obmin/fp/product.dart';
import 'package:obmin/fp/zipped.dart';

final class NonEmptyList<T> {
  final T head;
  final IList<T> tail;

  const NonEmptyList({
    required this.head,
    this.tail = const IList.empty(),
  });

  static Optional<NonEmptyList<T>> fromIList<T>(IList<T> list) {
    if (list.isEmpty) {
      return Optional.none();
    }
    return Optional.some(
      NonEmptyList(
        head: list.first,
        tail: list.removeAt(0),
      ),
    );
  }

  IList<T> toIList() {
    return [head].lock.addAll(tail);
  }

  NonEmptyList<R> mapIndexed<R>(R Function(int index, T value) function) {
    final mappedHead = function(0, head);
    final mappedTail = tail.mapIndexed((index, value) {
      return function(index + 1, value);
    }).toIList();
    return NonEmptyList(
      head: mappedHead,
      tail: mappedTail,
    );
  }

  NonEmptyList<R> map<R>(R Function(T value) function) {
    return mapIndexed((_, value) => function(value));
  }

  NonEmptyList<R> bindIndexed<R>(NonEmptyList<R> Function(int index, T value) function) {
    final mappedHeadNonEmptyList = function(0, head);

    final resultHead = mappedHeadNonEmptyList.head;
    IList<R> resultTail = mappedHeadNonEmptyList.tail;

    for (int i = 0; i < tail.length; i++) {
      final item = tail[i];

      resultTail = resultTail.addAll(function(i + 1, item).toIList());
    }

    return NonEmptyList(
      head: resultHead,
      tail: resultTail,
    );
  }

  NonEmptyList<R> bind<R>(NonEmptyList<R> Function(T value) function) {
    return bindIndexed((_, value) => function(value));
  }

  R foldIndexed<R>(R initialValue, R Function(R acc, int index, T value) function) {
    R result = function(initialValue, 0, head);

    for (int i = 0; i < tail.length; i++) {
      final item = tail[i];
      result = function(result, i + 1, item);
    }

    return result;
  }

  R fold<R>(R initialValue, R Function(R acc, T value) function) {
    return foldIndexed(initialValue, (acc, _, value) => function(acc, value));
  }

  void forEachIndexed(void Function(int index, T value) action) {
    action(0, head);
    tail.forEachIndexed((index, value) => action(index + 1, value));
  }

  void forEach(void Function(T value) action) {
    forEachIndexed((_, value) => action(value));
  }

  NonEmptyList<R> zipWith<R, U>(
    NonEmptyList<U> other,
    R Function(int index, Zipped<T, U> element) combine,
  ) {
    final IList<T> list1 = toIList();
    final IList<U> list2 = other.toIList();

    final int length = list1.length > list2.length ? list1.length : list2.length;

    IList<R> result = const IList.empty();

    for (int i = 0; i < length; i++) {
      if (i < list1.length && i < list2.length) {
        result = result.add(combine(i, Zipped.both(list1[i], list2[i])));
      } else if (i < list1.length) {
        result = result.add(combine(i, Zipped.left(list1[i])));
      } else {
        result = result.add(combine(i, Zipped.right(list2[i])));
      }
    }

    return NonEmptyList<R>(
      head: result.first,
      tail: result.removeAt(0),
    );
  }

  NonEmptyList<T> get reversed {
    if (tail.isEmpty) {
      return NonEmptyList(head: head, tail: const IList.empty());
    }

    final reversedTail = tail.reversed;
    return NonEmptyList(
      head: reversedTail.first,
      tail: reversedTail.removeAt(0).add(head),
    );
  }

  Optional<T> getOrNone(int index) {
    if (index == 0) return Optional.some(head);
    if (index - 1 < tail.length) return Optional.some(tail[index - 1]);
    return Optional.none();
  }

  int get length => tail.length + 1;

  Optional<T> findWhereIndexed(bool Function(int index, T value) predicate) {
    if (predicate(0, head)) {
      return Optional.some(head);
    }

    for (int i = 0; i < tail.length; i++) {
      final element = tail[i];
      if (predicate(i + 1, element)) {
        return Optional.some(element);
      }
    }

    return Optional.none();
  }

  Optional<T> findWhere(bool Function(T value) predicate) {
    return findWhereIndexed((_, value) => predicate(value));
  }

  bool contains(T value) {
    return containsWhere((iValue) => iValue == value);
  }

  bool containsWhereIndexed(bool Function(int index, T value) predicate) {
    return findWhereIndexed((index, value) => predicate(index, value)).isSome;
  }

  bool containsWhere(bool Function(T value) predicate) {
    return containsWhereIndexed((_, value) => predicate(value));
  }

  NonEmptyList<T> add(T value) {
    return NonEmptyList(head: head, tail: tail.add(value));
  }

  NonEmptyList<T> addAll(NonEmptyList<T> other) {
    return NonEmptyList(head: head, tail: tail.addAll(other.toIList()));
  }

  Optional<NonEmptyList<T>> insertAt(int index, T element) {
    return insertAllAt(
      index,
      NonEmptyList(
        head: element,
        tail: const IList.empty(),
      ),
    );
  }

  Optional<NonEmptyList<T>> insertAllAt(int index, NonEmptyList<T> elements) {
    if (index < 0 || index > 1 + tail.length) return Optional.none();

    if (index == 0) {
      return Optional.some(
        NonEmptyList(
          head: elements.head,
          tail: elements.tail.add(head).addAll(tail),
        ),
      );
    } else {
      final newTail = tail.insert(index - 1, elements.head).insertAll(index, elements.tail);
      return Optional.some(NonEmptyList(head: head, tail: newTail));
    }
  }

  Optional<NonEmptyList<T>> removeWhereIndexed(bool Function(int index, T value) predicate) {
    final filteredTail = tail.whereIndexed((index, value) => !predicate(index + 1, value)).toIList();

    if (!predicate(0, head)) {
      return Optional.some(
        NonEmptyList(
          head: head,
          tail: filteredTail,
        ),
      );
    } else if (filteredTail.isNotEmpty) {
      return Optional.some(
        NonEmptyList(
          head: filteredTail.first,
          tail: filteredTail.removeAt(0),
        ),
      );
    }
    return Optional.none();
  }

  Optional<NonEmptyList<T>> removeWhere(bool Function(T value) predicate) {
    return removeWhereIndexed((_, value) => predicate(value));
  }

  Optional<NonEmptyList<T>> removeLast() {
    if (tail.isEmpty) {
      return Optional.none();
    } else {
      return Optional.some(
        NonEmptyList(
          head: head,
          tail: tail.removeLast(),
        ),
      );
    }
  }

  Optional<NonEmptyList<T>> removeLastN(int numberOfElements) {
    if (length <= numberOfElements) {
      return Optional.none();
    }

    IList<T> result = tail;
    for (int i = 0; i < numberOfElements; i++) {
      result = result.removeLast();
    }

    return Optional.some(NonEmptyList(head: head, tail: result));
  }

  Optional<NonEmptyList<T>> removeAt(int index) {
    if (index < 0 || index >= length) {
      return Optional.none();
    }

    if (index == 0) {
      if (tail.isEmpty) {
        return Optional.none();
      }
      return Optional.some(
        NonEmptyList(
          head: tail.first,
          tail: tail.removeAt(0),
        ),
      );
    } else {
      final newTail = tail.removeAt(index - 1);
      return Optional.some(
        NonEmptyList(
          head: head,
          tail: newTail,
        ),
      );
    }
  }

  Optional<NonEmptyList<T>> removeAllAt(IList<int> indices) {
    if (indices.isEmpty) return Optional.some(this);

    final sortedIndices = indices.toISet().toIList().sort();

    if (sortedIndices.any((index) => index < 0 || index >= 1 + tail.length)) {
      return Optional.none();
    }

    IList<T> fullList = [head, ...tail].lock;

    for (int i = sortedIndices.length - 1; i >= 0; i--) {
      fullList = fullList.removeAt(sortedIndices[i]);
    }

    if (fullList.isEmpty) {
      return Optional.none();
    }

    return Optional.some(
      NonEmptyList(
        head: fullList.first,
        tail: fullList.removeAt(0),
      ),
    );
  }

  Optional<NonEmptyList<T>> swap(int index1, int index2) {
    final totalLength = 1 + tail.length;

    if (index1 < 0 || index2 < 0 || index1 >= totalLength || index2 >= totalLength) {
      return Optional.none();
    }

    if (index1 == index2) return Optional.some(this);

    IList<T> fullList = [head, ...tail].lock;

    final temp = fullList[index1];

    fullList = fullList.replace(index1, fullList[index2]).replace(index2, temp);

    return Optional.some(
      NonEmptyList(
        head: fullList.first,
        tail: fullList.removeAt(0),
      ),
    );
  }

  NonEmptySet<Product<int, T>> asNonEmptySet() {
    return NonEmptySet(
      any: Product(0, head),
      rest: tail.mapIndexed(Product.new).toISet(),
    );
  }

  @override
  String toString() {
    return "NonEmptyList<$T> { head=$head, tail=$tail }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NonEmptyList<T>) return false;
    return head == other.head && tail == other.tail;
  }

  @override
  int get hashCode => head.hashCode ^ tail.hashCode;
}

extension OptionalOfNonEmptyListToIListExtension<Element> on Optional<NonEmptyList<Element>> {
  IList<Element> toIList() {
    return fold(
      (value) => value.toIList(),
      () => const IList.empty(),
    );
  }
}
