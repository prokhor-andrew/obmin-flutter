// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/optional.dart';
import 'package:obmin/utils/bool_fold.dart';
import 'package:obmin/utils/list_plus.dart';

final class NonEmptyIterable<T> {
  final T head;
  final Iterable<T> tail;

  const NonEmptyIterable({
    required this.head,
    required this.tail,
  });

  static Optional<NonEmptyIterable<T>> fromIterable<T>(Iterable<T> iterable) {
    return iterable.isEmpty.fold(
      Optional.none,
      () {
        return Optional.some(
          NonEmptyIterable(
            head: iterable.first,
            tail: iterable.toList().sublist(1),
          ),
        );
      },
    );
  }

  NonEmptyIterable<R> map<R>(R Function(T value) function) {
    final mappedHead = function(head);
    final mappedTail = tail.map(function);
    return NonEmptyIterable(head: mappedHead, tail: mappedTail);
  }

  Iterable<T> asIterable() {
    return [head].plusMultiple(tail.toList());
  }

  @override
  String toString() {
    return "NonEmptyIterable<$T> { head=$head, tail=$tail }";
  }
}
