// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:meta/meta.dart';
import 'package:obmin/fp/optional.dart';
import 'package:obmin/utils/bool_fold.dart';

@immutable
final class Either<L, R> {
  final bool _isLeft;
  final L? _left;
  final R? _right;

  const Either.left(L left)
      : _left = left,
        _right = null,
        _isLeft = true;

  const Either.right(R right)
      : _right = right,
        _left = null,
        _isLeft = false;

  @useResult
  T fold<T>(
    T Function(L value) ifLeft,
    T Function(R value) ifRight,
  ) {
    return _isLeft.fold<T>(
      () => ifLeft(_left!),
      () => ifRight(_right!),
    );
  }

  @useResult
  T combineWith<T, L2, R2>(
    Either<L2, R2> other, {
    required T Function(L value, L2 otherValue) ifLeftLeft,
    required T Function(L value, R2 otherValue) ifLeftRight,
    required T Function(R value, L2 otherValue) ifRightLeft,
    required T Function(R value, R2 otherValue) ifRightRight,
  }) {
    return fold(
      (value) => other.fold(
        (otherValue) => ifLeftLeft(value, otherValue),
        (otherValue) => ifLeftRight(value, otherValue),
      ),
      (value) => other.fold(
        (otherValue) => ifRightLeft(value, otherValue),
        (otherValue) => ifRightRight(value, otherValue),
      ),
    );
  }

  @useResult
  T combineWithOrElseLazy<T, L2, R2>(
    Either<L2, R2> other, {
    T Function(L value, L2 otherValue)? ifLeftLeft,
    T Function(L value, R2 otherValue)? ifLeftRight,
    T Function(R value, L2 otherValue)? ifRightLeft,
    T Function(R value, R2 otherValue)? ifRightRight,
    required T Function() orElse,
  }) {
    return combineWith(
      other,
      ifLeftLeft: ifLeftLeft ?? (_, __) => orElse(),
      ifLeftRight: ifLeftRight ?? (_, __) => orElse(),
      ifRightLeft: ifRightLeft ?? (_, __) => orElse(),
      ifRightRight: ifRightRight ?? (_, __) => orElse(),
    );
  }

  @useResult
  T combineWithOrElse<T, L2, R2>(
    Either<L2, R2> other, {
    T Function(L value, L2 otherValue)? ifLeftLeft,
    T Function(L value, R2 otherValue)? ifLeftRight,
    T Function(R value, L2 otherValue)? ifRightLeft,
    T Function(R value, R2 otherValue)? ifRightRight,
    required T orElse,
  }) {
    return combineWithOrElseLazy(
      other,
      ifLeftLeft: ifLeftLeft,
      ifLeftRight: ifLeftRight,
      ifRightLeft: ifRightLeft,
      ifRightRight: ifRightRight,
      orElse: () => orElse,
    );
  }

  @useResult
  @override
  String toString() {
    return fold<String>(
      (value) => "Either.left<$L, $R> { value=$value }",
      (value) => "Either.right<$L, $R> { value=$value }",
    );
  }

  @useResult
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Either<L, R>) return false;

    return combineWith(
      other,
      ifLeftLeft: (value1, value2) => value1 == value2,
      ifLeftRight: (value1, value2) => false,
      ifRightLeft: (value1, value2) => false,
      ifRightRight: (value1, value2) => value1 == value2,
    );
  }

  @useResult
  @override
  int get hashCode => fold(
        (value) => value.hashCode,
        (value) => value.hashCode,
      );

  @useResult
  Either<T, R> bindLeft<T>(Either<T, R> Function(L value) function) {
    return fold<Either<T, R>>(
      function,
      Either<T, R>.right,
    );
  }

  @useResult
  Either<T, R> mapLeft<T>(T Function(L value) function) {
    return bindLeft<T>((value) => Either<T, R>.left(function(value)));
  }

  @useResult
  Either<T, R> mapLeftToLazy<T>(T Function() function) {
    return mapLeft<T>((_) => function());
  }

  @useResult
  Either<T, R> mapLeftTo<T>(T value) {
    return mapLeftToLazy<T>(() => value);
  }

  @useResult
  Either<L, T> bindRight<T>(Either<L, T> Function(R value) function) {
    return fold<Either<L, T>>(
      Either<L, T>.left,
      function,
    );
  }

  @useResult
  Either<L, T> mapRight<T>(T Function(R value) function) {
    return swapped.mapLeft<T>(function).swapped;
  }

  @useResult
  Either<L, T> mapRightToLazy<T>(T Function() function) {
    return mapRight((_) => function());
  }

  @useResult
  Either<L, T> mapRightTo<T>(T value) {
    return mapRightToLazy<T>(() => value);
  }

  @useResult
  Either<L, R2> apLeft<R2>(Either<L, R2 Function(R)> eitherWithFunction) {
    return fold(
      Either.left,
      (value) => eitherWithFunction.fold(
        Either.left,
        (function) => Either.right(function(value)),
      ),
    );
  }

  @useResult
  Either<L2, R> apRight<L2>(Either<L2 Function(L), R> eitherWithFunction) {
    return swapped.apLeft(eitherWithFunction.swapped).swapped;
  }

  void runIfLeft(void Function(L value) function) {
    fold<void Function()>(
      (value) => () => function(value),
      (_) => () {},
    )();
  }

  void runIfRight(void Function(R value) function) {
    swapped.runIfLeft(function);
  }

  static void _doNothing(dynamic a, dynamic b) {}

  void runWith<L2, R2>(
    Either<L2, R2> other, {
    void Function(L value, L2 otherValue) ifLeftLeft = _doNothing,
    void Function(L value, R2 otherValue) ifLeftRight = _doNothing,
    void Function(R value, L2 otherValue) ifRightLeft = _doNothing,
    void Function(R value, R2 otherValue) ifRightRight = _doNothing,
  }) {
    combineWith(
      other,
      ifLeftLeft: (value1, value2) => () => ifLeftLeft(value1, value2),
      ifLeftRight: (value1, value2) => () => ifLeftRight(value1, value2),
      ifRightLeft: (value1, value2) => () => ifRightLeft(value1, value2),
      ifRightRight: (value1, value2) => () => ifRightRight(value1, value2),
    )();
  }

  @useResult
  Either<R, L> get swapped => fold<Either<R, L>>(
        Either<R, L>.right,
        Either<R, L>.left,
      );

  @useResult
  Optional<L> get leftOrNone => fold(
        Optional.some,
        (right) => const Optional.none(),
      );

  @useResult
  Optional<R> get rightOrNone => swapped.leftOrNone;

  @useResult
  bool get isLeft => leftOrNone.isSome;

  @useResult
  bool get isRight => !isLeft;
}

extension EitherValueWhenBothExtension<T> on Either<T, T> {
  @useResult
  T get value => fold<T>(
        (val) => val,
        (val) => val,
      );
}
