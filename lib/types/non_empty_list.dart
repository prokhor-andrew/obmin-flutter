// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:collection/collection.dart';
import 'package:obmin/types/non_empty_set.dart';
import 'package:obmin/types/optional.dart';
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

  NonEmptyList<R> map<R>(R Function(T value) function) {
    final mappedHead = function(head);
    final mappedTail = tail.map(function).toList();
    return NonEmptyList(
      head: mappedHead,
      tail: mappedTail,
    );
  }

  NonEmptyList<R> bind<R>(NonEmptyList<R> Function(T value) function) {
    final mappedHeadNonEmptyList = function(head);

    final List<R> resultTail = mappedHeadNonEmptyList.tail.toList();

    for (final item in tail.toList()) {
      resultTail.addAll(function(item).asList());
    }

    return NonEmptyList(
      head: mappedHeadNonEmptyList.head,
      tail: resultTail,
    );
  }

  R fold<R>(R initialValue, R Function(R acc, T value) function) {
    R result = function(initialValue, head);
    for (final item in tail.toList()) {
      result = function(result, item);
    }
    return result;
  }

  NonEmptyList<R> ap<R>(NonEmptyList<R Function(T)> listOfFunctions) {
    final appliedHead = listOfFunctions.head(head);
    final appliedTail = [
      ...listOfFunctions.tail.map((fn) => fn(head)),
      ...listOfFunctions.asList().skip(1).expand((fn) => tail.map(fn)),
    ];
    return NonEmptyList(head: appliedHead, tail: appliedTail);
  }

  Optional<NonEmptyList<T>> filter(bool Function(T value) predicate) {
    final filteredTail = tail.where(predicate).toList();
    if (predicate(head)) {
      return Optional.some(NonEmptyList(head: head, tail: filteredTail));
    } else if (filteredTail.isNotEmpty) {
      return Optional.some(NonEmptyList(head: filteredTail.first, tail: filteredTail.skip(1).toList()));
    }
    return Optional.none();
  }

  void forEach(void Function(T value) action) {
    action(head);
    tail.toList().forEach(action);
  }

  NonEmptyList<R> zipWith<R, U>(NonEmptyList<U> other, R Function(T value1, U value2) combine) {
    final tailCopy = tail.toList();
    final otherTailCopy = other.tail.toList();

    final minLength = tailCopy.length < otherTailCopy.length ? tailCopy.length : otherTailCopy.length;
    final zippedTail = List<R>.generate(minLength, (i) => combine(tailCopy[i], otherTailCopy[i]));
    return NonEmptyList(head: combine(head, other.head), tail: zippedTail);
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

  Optional<T> findWhere(bool Function(T value) predicate) {
    if (predicate(head)) {
      return Optional.some(head);
    }

    for (final element in tail.toList()) {
      if (predicate(element)) {
        return Optional.some(element);
      }
    }

    return Optional.none();
  }

  bool contains(T value) {
    return containsWhere((iValue) => iValue == value);
  }

  bool containsWhere(bool Function(T value) predicate) {
    return findWhere(predicate).isSome;
  }

  NonEmptySet<T> asNonEmptySet() {
    return NonEmptySet(
      any: head,
      rest: tail.toSet(),
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
