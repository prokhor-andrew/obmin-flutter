// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:meta/meta.dart';
import 'package:obmin/fp/either.dart';
import 'package:obmin/utils/bool_fold.dart';

@immutable
final class Optional<T> {
  final bool _isSome;
  final T? _value;

  const Optional.some(T value)
      : _value = value,
        _isSome = true;

  @literal
  const Optional.none()
      : _value = null,
        _isSome = false;

  @useResult
  V fold<V>(
    V Function(T value) ifSome,
    V Function() ifNone,
  ) {
    return _isSome.fold<V>(
      () => ifSome(_value!),
      ifNone,
    );
  }

  @useResult
  R combineWith<R, T2>(
    Optional<T2> other, {
    required R Function(T value1, T2 value2) ifBoth,
    required R Function(T value) ifLeft,
    required R Function(T2 value) ifRight,
    required R Function() ifNone,
  }) {
    return fold(
      (value) => other.fold(
        (value2) => ifBoth(value, value2),
        () => ifLeft(value),
      ),
      () => other.fold(
        (value) => ifRight(value),
        ifNone,
      ),
    );
  }

  @useResult
  R combineWithOrElseLazy<R, T2>(
    Optional<T2> other, {
    R Function(T value1, T2 value2)? ifBoth,
    R Function(T value)? ifLeft,
    R Function(T2 value)? ifRight,
    R Function()? ifNone,
    required R Function() orElse,
  }) {
    return combineWith(
      other,
      ifBoth: ifBoth ?? (_, __) => orElse(),
      ifLeft: ifLeft ?? (_) => orElse(),
      ifRight: ifRight ?? (_) => orElse(),
      ifNone: ifNone ?? () => orElse(),
    );
  }

  @useResult
  R combineWithOrElse<R, T2>(
    Optional<T2> other, {
    R Function(T value1, T2 value2)? ifBoth,
    R Function(T value)? ifLeft,
    R Function(T2 value)? ifRight,
    R Function()? ifNone,
    required R orElse,
  }) {
    return combineWithOrElseLazy(
      other,
      ifBoth: ifBoth,
      ifLeft: ifLeft,
      ifRight: ifRight,
      ifNone: ifNone,
      orElse: () => orElse,
    );
  }

  @useResult
  @override
  String toString() {
    return fold<String>(
      (value) => "Optional.some<$T> { value=$value }",
      () => "Optional.none<$T>",
    );
  }

  @useResult
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Optional<T>) return false;

    return combineWith(
      other,
      ifBoth: (value1, value2) => value1 == value2,
      ifLeft: (_) => false,
      ifRight: (_) => false,
      ifNone: () => true,
    );
  }

  @useResult
  @override
  int get hashCode => fold(
        (value) => value.hashCode,
        () => 0,
      );

  @useResult
  Optional<R> bind<R>(Optional<R> Function(T value) function) {
    return fold(
      function,
      Optional.none,
    );
  }

  @useResult
  Optional<R> map<R>(R Function(T value) function) {
    return bind((value) {
      return Optional<R>.some(function(value));
    });
  }

  @useResult
  Optional<R> ap<R>(Optional<R Function(T)> optionalWithFunc) {
    return combineWith(
      optionalWithFunc,
      ifBoth: (value, function) => Optional.some(function(value)),
      ifLeft: (_) => const Optional.none(),
      ifRight: (_) => const Optional.none(),
      ifNone: () => const Optional.none(),
    );
  }

  @useResult
  Either<T, ()> asEither() => fold(Either.left, () => Either.right(()));

  @useResult
  Optional<R> zipWith<T2, R>(
    Optional<T2> other,
    R Function(T value1, T2 value2) function,
  ) {
    final curried = (T val1) => (T2 val2) => function(val1, val2);
    return other.ap(map(curried));
  }

  @useResult
  Optional<R> mapToLazy<R>(R Function() function) {
    return map((_) => function());
  }

  @useResult
  Optional<R> mapTo<R>(R value) {
    return mapToLazy<R>(() => value);
  }

  @useResult
  T valueOrLazy(T Function() replacementFunc) {
    return fold(
      (value) => value,
      replacementFunc,
    );
  }

  @useResult
  T valueOr(T replacement) {
    return valueOrLazy(() => replacement);
  }

  @useResult
  bool get isSome => fold(
        (_) => true,
        () => false,
      );

  @useResult
  bool get isNone => !isSome;

  @useResult
  T force() {
    return fold<T>(
      (val) => val,
      () => throw "None<$T> is being forcefully unwrapped",
    );
  }

  void runIfSome(void Function(T value) function) {
    fold(
      (value) => () => function(value),
      () => () {},
    )();
  }

  void runIfNone(void Function() function) {
    fold(
      (_) => () {},
      () => function,
    )();
  }

  static void _doNothingA(dynamic a, dynamic b) {}

  static void _doNothingB(dynamic a) {}

  static void _doNothingC() {}

  void runWith<T2>(
    Optional<T2> other, {
    void Function(T value1, T2 value2) ifBoth = _doNothingA,
    void Function(T value) ifLeft = _doNothingB,
    void Function(T2 value) ifRight = _doNothingB,
    void Function() ifNone = _doNothingC,
  }) {
    combineWith(
      other,
      ifBoth: (value1, value2) => () => ifBoth(value1, value2),
      ifLeft: (value) => () => ifLeft(value),
      ifRight: (value) => () => ifRight(value),
      ifNone: () => () => ifNone(),
    )();
  }
}