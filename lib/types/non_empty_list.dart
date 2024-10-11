// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:collection/collection.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/non_empty_set.dart';
import 'package:obmin/types/optional.dart';
import 'package:obmin/types/product.dart';
import 'package:obmin/utils/list_minus.dart';
import 'package:obmin/utils/list_plus.dart';

final class NonEmptyList<T> {
  final T head;
  final List<T> tail;

  const NonEmptyList({
    required this.head,
    required this.tail,
  });

  static Optional<NonEmptyList<T>> fromList<T>(List<T> list) {
    if (list.isEmpty) {
      return Optional.none();
    }
    return Optional.some(
      NonEmptyList(
        head: list.first,
        tail: list.sublist(1),
      ),
    );
  }

  List<T> asList() {
    return [head].plusMultiple(tail);
  }

  NonEmptyList<R> mapIndexed<R>(R Function(int index, T value) function) {
    final mappedHead = function(0, head);
    final mappedTail = tail.mapIndexed((index, value) {
      return function(index + 1, value);
    }).toList();
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

    final List<R> resultTail = mappedHeadNonEmptyList.tail.toList();

    final copy = tail.toList();
    for (int i = 0; i < copy.length; i++) {
      final item = copy[i];
      resultTail.addAll(function(i + 1, item).asList());
    }

    return NonEmptyList(
      head: mappedHeadNonEmptyList.head,
      tail: resultTail,
    );
  }

  NonEmptyList<R> bind<R>(NonEmptyList<R> Function(T value) function) {
    return bindIndexed((_, value) => function(value));
  }

  R foldIndexed<R>(R initialValue, R Function(R acc, int index, T value) function) {
    R result = function(initialValue, 0, head);

    final copy = tail.toList();
    for (int i = 0; i < copy.length; i++) {
      final item = copy[i];
      result = function(result, i + 1, item);
    }

    return result;
  }

  R fold<R>(R initialValue, R Function(R acc, T value) function) {
    return foldIndexed(initialValue, (acc, _, value) => function(acc, value));
  }

  NonEmptyList<R> ap<R>(NonEmptyList<R Function(T)> listOfFunctions) {
    final appliedHead = listOfFunctions.head(head);
    final appliedTail = [
      ...listOfFunctions.tail.map((fn) => fn(head)),
      ...listOfFunctions.asList().skip(1).expand((fn) => tail.map(fn)),
    ];
    return NonEmptyList(head: appliedHead, tail: appliedTail);
  }

  Optional<NonEmptyList<T>> filterIndexed(bool Function(int index, T value) predicate) {
    final filteredTail = tail.whereIndexed((index, value) => predicate(index + 1, value)).toList();
    if (predicate(0, head)) {
      return Optional.some(NonEmptyList(head: head, tail: filteredTail));
    } else if (filteredTail.isNotEmpty) {
      return Optional.some(NonEmptyList(head: filteredTail.first, tail: filteredTail.skip(1).toList()));
    }
    return Optional.none();
  }

  Optional<NonEmptyList<T>> filter(bool Function(T value) predicate) {
    return filterIndexed((_, value) => predicate(value));
  }

  void forEachIndexed(void Function(int index, T value) action) {
    action(0, head);
    tail.toList().forEachIndexed((index, value) => action(index + 1, value));
  }

  void forEach(void Function(T value) action) {
    forEachIndexed((_, value) => action(value));
  }

  NonEmptyList<R> zipWith<R, U>(
    NonEmptyList<U> other,
    R Function(int index, Either<Product<T, U>, Either<T, U>>) combine,
  ) {
    List<T> list1 = [head, ...tail];
    List<U> list2 = [other.head, ...other.tail];

    List<R> result = [];
    int length = list1.length > list2.length ? list1.length : list2.length;

    for (int i = 0; i < length; i++) {
      if (i < list1.length && i < list2.length) {
        result.add(combine(i, Either.left(Product(list1[i], list2[i]))));
      } else if (i < list1.length) {
        result.add(combine(i, Either.right(Either.left(list1[i]))));
      } else {
        result.add(combine(i, Either.right(Either.right(list2[i]))));
      }
    }

    return NonEmptyList<R>(
      head: result.first,
      tail: result.skip(1).toList(),
    );
  }

  NonEmptyList<T> get reversed {
    final reversedTail = [...tail.toList().reversed];
    return NonEmptyList(
      head: reversedTail.isEmpty ? head : reversedTail.first,
      tail: reversedTail.skip(1).toList()..add(head),
    );
  }

  Optional<T> getOrNone(int index) {
    final tailCopy = tail.toList();
    if (index == 0) return Optional.some(head);
    if (index - 1 < tailCopy.length) return Optional.some(tailCopy[index - 1]);
    return Optional.none();
  }

  NonEmptyList<T> plusAtStart(T value) {
    return NonEmptyList(head: value, tail: [head, ...tail.toList()]);
  }

  NonEmptyList<T> plusMultipleAtStart(NonEmptyList<T> other) {
    return NonEmptyList(head: other.head, tail: [...other.tail.toList(), head, ...tail.toList()]);
  }

  NonEmptyList<T> plusAtEnd(T value) {
    return NonEmptyList(head: head, tail: [...tail.toList(), value]);
  }

  NonEmptyList<T> plusMultipleAtEnd(NonEmptyList<T> other) {
    return NonEmptyList(head: head, tail: [...tail.toList(), other.head, ...other.tail.toList()]);
  }

  Optional<NonEmptyList<T>> insertAt(int index, T element) {
    final tailCopy = tail.toList();
    if (index < 0 || index > 1 + tailCopy.length) return Optional.none();

    if (index == 0) {
      return Optional.some(NonEmptyList(head: element, tail: [head, ...tailCopy]));
    } else {
      final newTail = [...tailCopy];
      newTail.insert(index - 1, element);
      return Optional.some(NonEmptyList(head: head, tail: newTail));
    }
  }

  Optional<NonEmptyList<T>> insertAtMultiple(int index, NonEmptyList<T> elements) {
    final tailCopy = tail.toList();
    if (index < 0 || index > 1 + tailCopy.length) return Optional.none();

    if (index == 0) {
      return Optional.some(
        NonEmptyList(
          head: elements.head,
          tail: [
            ...elements.tail.toList(),
            head,
            ...tailCopy,
          ],
        ),
      );
    } else {
      final newTail = [...tailCopy];
      newTail.insert(index - 1, elements.head);
      newTail.insertAll(index, elements.tail.toList());
      return Optional.some(NonEmptyList(head: head, tail: newTail));
    }
  }

  List<T> minusFirst() {
    return tail.toList();
  }

  List<T> minusLast() {
    final tailCopy = tail.toList();
    if (tailCopy.isEmpty) {
      return [];
    } else {
      return [head].plusMultiple(tailCopy.minusLast());
    }
  }

  List<T> minusFirstMultiple(int n) {
    if (n <= 0) {
      return asList();
    }
    if (n >= length) {
      return [];
    }

    return tail.toList().sublist(n - 1);
  }

  List<T> minusLastMultiple(int n) {
    final tailCopy = tail.toList();
    if (n <= 0) {
      return asList();
    }
    if (n >= length) {
      return [];
    }

    return [head] + tailCopy.sublist(0, tailCopy.length - n);
  }

  Optional<NonEmptyList<T>> removeAt(int index) {
    final tailCopy = tail.toList();
    final totalLength = 1 + tailCopy.length;

    if (index < 0 || index >= totalLength) {
      return Optional.none();
    }

    if (index == 0) {
      if (tailCopy.isEmpty) {
        return Optional.none();
      }
      return Optional.some(NonEmptyList(
        head: tailCopy.first,
        tail: tailCopy.skip(1).toList(),
      ));
    } else {
      final newTail = [...tailCopy];
      newTail.removeAt(index - 1); // Remove the element at the index
      return Optional.some(NonEmptyList(
        head: head,
        tail: newTail,
      ));
    }
  }

  Optional<NonEmptyList<T>> removeAtMultiple(List<int> indices) {
    final tailCopy = tail.toList();

    if (indices.isEmpty) return Optional.some(this); // No change if no indices are provided

    // Ensure indices are unique and sorted
    final sortedIndices = indices.toSet().toList()..sort();

    // Validate indices
    if (sortedIndices.any((index) => index < 0 || index >= 1 + tailCopy.length)) {
      return Optional.none();
    }

    final List<T> fullList = [head, ...tailCopy];
    final List<T> newList = List.from(fullList);

    // Remove elements at specified indices (in reverse order to avoid shifting issues)
    for (int i = sortedIndices.length - 1; i >= 0; i--) {
      newList.removeAt(sortedIndices[i]);
    }

    if (newList.isEmpty) {
      return Optional.none();
    }

    return Optional.some(
      NonEmptyList(
        head: newList.first,
        tail: newList.skip(1).toList(),
      ),
    );
  }

  Optional<NonEmptyList<T>> swap(int index1, int index2) {
    final tailCopy = tail.toList();
    final totalLength = 1 + tailCopy.length;

    if (index1 < 0 || index2 < 0 || index1 >= totalLength || index2 >= totalLength) {
      return Optional.none(); // Return null if indices are out of bounds
    }

    if (index1 == index2) return Optional.some(this);

    final List<T> fullList = [head, ...tailCopy];

    final temp = fullList[index1];
    fullList[index1] = fullList[index2];
    fullList[index2] = temp;

    return Optional.some(NonEmptyList(head: fullList.first, tail: fullList.skip(1).toList()));
  }

  int get length => tail.length + 1;

  Optional<T> findWhereIndexed(bool Function(int index, T value) predicate) {
    if (predicate(0, head)) {
      return Optional.some(head);
    }

    final copy = tail.toList();
    for (int i = 0; i < copy.length; i++) {
      final element = copy[i];
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

  NonEmptySet<Product<int, T>> asNonEmptySet() {
    return NonEmptySet(
      any: Product(0, head),
      rest: tail.mapIndexed(Product.new).toSet(),
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
    final listEquality = ListEquality<T>();
    return head == other.head && listEquality.equals(tail, other.tail);
  }

  @override
  int get hashCode {
    final listEquality = ListEquality<T>();
    return Object.hash(head, listEquality.hash(tail));
  }
}
