// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:meta/meta.dart';

@immutable
final class Identity<T> {
  final T value;

  const Identity(this.value);

  @useResult
  @override
  String toString() {
    return "Identity<$T> { value = $value }";
  }

  @useResult
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Identity<T>) return false;

    return value == other.value;
  }

  @useResult
  @override
  int get hashCode => value.hashCode;

  @useResult
  R fold<R>(R Function(T value) function) {
    return function(value);
  }

  @useResult
  R combineWith<T2, R>(
    Identity<T2> other,
    R Function(T value1, T2 value2) function,
  ) {
    return function(value, other.value);
  }

  @useResult
  Identity<R> map<R>(R Function(T value) function) {
    return Identity(function(value));
  }

  @useResult
  Identity<R> mapToLazy<R>(R Function() function) {
    return Identity(function());
  }

  @useResult
  Identity<R> mapTo<R>(R value) {
    return mapToLazy(() => value);
  }

  @useResult
  Identity<R> bind<R>(Identity<R> Function(T value) function) {
    return function(value);
  }

  @useResult
  Identity<R> ap<R>(Identity<R Function(T)> identityWithFunc) => Identity(identityWithFunc.value(value));

  @useResult
  Identity<R> zipWithOther<R, T2>(
    Identity<T2> other,
    R Function(T value1, T2 value2) function,
  ) {
    final curried = (T value1) => (T2 value2) => function(value1, value2);
    return other.ap(map(curried));
  }

  void run(void Function(T value) function) {
    function(value);
  }

  void runWith<T2>(
    Identity<T2> other,
    void Function(T value1, T2 value2) function,
  ) {
    combineWith(other, (value1, value2) => () => function(value1, value2))();
  }
}
