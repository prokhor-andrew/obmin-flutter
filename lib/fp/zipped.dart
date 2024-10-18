// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:meta/meta.dart';
import 'package:obmin/fp/either.dart';
import 'package:obmin/fp/optional.dart';
import 'package:obmin/fp/product.dart';

@immutable
final class Zipped<L, R> {
  final L? _left;
  final R? _right;
  final bool? _isLeft;

  const Zipped.left(L value)
      : _left = value,
        _right = null,
        _isLeft = true;

  const Zipped.right(R value)
      : _left = null,
        _right = value,
        _isLeft = false;

  const Zipped.both(L value1, R value2)
      : _left = value1,
        _right = value2,
        _isLeft = null;

  @useResult
  T fold<T>(
    T Function(L value) ifLeft,
    T Function(R value) ifRight,
    T Function(L left, R right) ifBoth,
  ) {
    if (_isLeft != null) {
      if (_isLeft) {
        return ifLeft(_left!);
      } else {
        return ifRight(_right!);
      }
    } else {
      return ifBoth(_left!, _right!);
    }
  }

  @useResult
  T combineWith<T, L2, R2>(
    Zipped<L2, R2> other, {
    required T Function(L left1, L2 left2) ifLeftLeft,
    required T Function(L left1, R2 right2) ifLeftRight,
    required T Function(L left1, L2 left2, R2 right2) ifLeftBoth,
    required T Function(R right1, L2 left2) ifRightLeft,
    required T Function(R right1, R2 right2) ifRightRight,
    required T Function(R right1, L2 left2, R2 right2) ifRightBoth,
    required T Function(L left, R right, L2 left2) ifBothLeft,
    required T Function(L left, R right, R2 right2) ifBothRight,
    required T Function(L left, R right, L2 left2, R2 right2) ifBothBoth,
  }) {
    return fold(
      (value) => other.fold(
        (value2) => ifLeftLeft(value, value2),
        (value2) => ifLeftRight(value, value2),
        (left2, right2) => ifLeftBoth(value, left2, right2),
      ),
      (value) => other.fold(
        (value2) => ifRightLeft(value, value2),
        (value2) => ifRightRight(value, value2),
        (left2, right2) => ifRightBoth(value, left2, right2),
      ),
      (left, right) => other.fold(
        (value2) => ifBothLeft(left, right, value2),
        (value2) => ifBothRight(left, right, value2),
        (left2, right2) => ifBothBoth(left, right, left2, right2),
      ),
    );
  }

  @useResult
  T combineWithOrElseLazy<T, L2, R2>(
    Zipped<L2, R2> other, {
    T Function(L left1, L2 left2)? ifLeftLeft,
    T Function(L left1, R2 right2)? ifLeftRight,
    T Function(L left1, L2 left2, R2 right2)? ifLeftBoth,
    T Function(R right1, L2 left2)? ifRightLeft,
    T Function(R right1, R2 right2)? ifRightRight,
    T Function(R right1, L2 left2, R2 right2)? ifRightBoth,
    T Function(L left, R right, L2 left2)? ifBothLeft,
    T Function(L left, R right, R2 right2)? ifBothRight,
    T Function(L left, R right, L2 left2, R2 right2)? ifBothBoth,
    required T Function() orElse,
  }) {
    return combineWith(
      other,
      ifLeftLeft: ifLeftLeft ?? (_, __) => orElse(),
      ifLeftRight: ifLeftRight ?? (_, __) => orElse(),
      ifLeftBoth: ifLeftBoth ?? (_, __, ___) => orElse(),
      ifRightLeft: ifRightLeft ?? (_, __) => orElse(),
      ifRightRight: ifRightRight ?? (_, __) => orElse(),
      ifRightBoth: ifRightBoth ?? (_, __, ___) => orElse(),
      ifBothLeft: ifBothLeft ?? (_, __, ___) => orElse(),
      ifBothRight: ifBothRight ?? (_, __, ___) => orElse(),
      ifBothBoth: ifBothBoth ?? (_, __, ___, ____) => orElse(),
    );
  }

  @useResult
  T combineWithOrElse<T, L2, R2>(
    Zipped<L2, R2> other, {
    T Function(L left1, L2 left2)? ifLeftLeft,
    T Function(L left1, R2 right2)? ifLeftRight,
    T Function(L left1, L2 left2, R2 right2)? ifLeftBoth,
    T Function(R right1, L2 left2)? ifRightLeft,
    T Function(R right1, R2 right2)? ifRightRight,
    T Function(R right1, L2 left2, R2 right2)? ifRightBoth,
    T Function(L left, R right, L2 left2)? ifBothLeft,
    T Function(L left, R right, R2 right2)? ifBothRight,
    T Function(L left, R right, L2 left2, R2 right2)? ifBothBoth,
    required T orElse,
  }) {
    return combineWithOrElseLazy(
      other,
      ifLeftLeft: ifLeftLeft,
      ifLeftRight: ifLeftRight,
      ifLeftBoth: ifLeftBoth,
      ifRightLeft: ifRightLeft,
      ifRightRight: ifRightRight,
      ifRightBoth: ifRightBoth,
      ifBothLeft: ifBothLeft,
      ifBothRight: ifBothRight,
      ifBothBoth: ifBothBoth,
      orElse: () => orElse,
    );
  }

  @useResult
  Zipped<V, R> mapLeft<V>(V Function(L value) function) {
    return fold(
      (value) => Zipped.left(function(value)),
      Zipped.right,
      (left, right) => Zipped.both(function(left), right),
    );
  }

  @useResult
  Zipped<V, R> mapLeftToLazy<V>(V Function() function) {
    return mapLeft((_) => function());
  }

  @useResult
  Zipped<V, R> mapLeftTo<V>(V value) {
    return mapLeftToLazy(() => value);
  }

  @useResult
  Zipped<L, V> mapRight<V>(V Function(R value) function) {
    return swapped.mapLeft(function).swapped;
  }

  @useResult
  Zipped<L, V> mapRightToLazy<V>(V Function() function) {
    return swapped.mapLeftToLazy(function).swapped;
  }

  @useResult
  Zipped<L, V> mapRightTo<V>(V value) {
    return swapped.mapLeftTo(value).swapped;
  }

  @useResult
  @override
  String toString() {
    return fold(
      (value) => "ZipElement.left<$L, $R> { left=$value }",
      (value) => "ZipElement.right<$L, $R> { right=$value }",
      (left, right) => "ZipElement.both<$L, $R> { left=$left, right=$right }",
    );
  }

  @useResult
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Zipped<L, R>) return false;

    return fold(
      (leftValue) => other.fold(
        (otherLeftValue) => leftValue == otherLeftValue,
        (_) => false,
        (_, __) => false,
      ),
      (rightValue) => other.fold(
        (_) => false,
        (otherRightValue) => rightValue == otherRightValue,
        (_, __) => false,
      ),
      (leftValue, rightValue) => other.fold(
        (_) => false,
        (_) => false,
        (otherLeftValue, otherRightValue) => leftValue == otherLeftValue && rightValue == otherRightValue,
      ),
    );
  }

  @useResult
  @override
  int get hashCode => fold(
        (value) => value.hashCode,
        (value) => value.hashCode,
        (left, right) => left.hashCode ^ right.hashCode,
      );

  @useResult
  bool get isBoth => fold(
        (_) => false,
        (_) => false,
        (_, __) => true,
      );

  @useResult
  bool get isLeft => fold(
        (_) => true,
        (_) => false,
        (_, __) => false,
      );

  @useResult
  bool get isRight => swapped.isLeft;

  @useResult
  Optional<L> get leftOrNone => fold(
        Optional.some,
        (_) => const Optional.none(),
        (_, __) => const Optional.none(),
      );

  @useResult
  Optional<R> get rightOrNone => swapped.leftOrNone;

  @useResult
  Optional<Product<L, R>> get bothOrNone => fold(
        (_) => const Optional.none(),
        (_) => const Optional.none(),
        (left, right) => Optional.some(
          Product(left, right),
        ),
      );

  @useResult
  Optional<Either<L, R>> get eitherOrNone => fold(
        (value) => Optional.some(Either.left(value)),
        (value) => Optional.some(Either.right(value)),
        (_, __) => const Optional.none(),
      );

  @useResult
  Optional<L> get leftOrLeftProductOrNone => fold(
        Optional.some,
        (_) => const Optional.none(),
        (value, _) => Optional.some(value),
      );

  @useResult
  Optional<R> get rightOrRightProductOrNone => fold(
        (_) => const Optional.none(),
        Optional.some,
        (_, value) => Optional.some(value),
      );

  @useResult
  Zipped<R, L> get swapped => fold(
        Zipped.right,
        Zipped.left,
        (left, right) => Zipped.both(right, left),
      );

  void runIfLeft(void Function(L value) function) {
    fold(
      (value) => () => function(value),
      (_) => () {},
      (_, __) => () {},
    )();
  }

  void runIfRight(void Function(R value) function) {
    swapped.runIfLeft(function);
  }

  void runIfBoth(void Function(L left, R right) function) {
    fold(
      (_) => () {},
      (_) => () {},
      (left, right) => () => function(left, right),
    )();
  }

  static void _doNothingA(dynamic a, dynamic b) {}

  static void _doNothingB(dynamic a, dynamic b, dynamic c) {}

  static void _doNothingC(dynamic a, dynamic b, dynamic c, dynamic d) {}

  void runWith<L2, R2>(
    Zipped<L2, R2> other, {
    void Function(L left1, L2 left2) ifLeftLeft = _doNothingA,
    void Function(L left1, R2 right2) ifLeftRight = _doNothingA,
    void Function(L left1, L2 left2, R2 right2) ifLeftBoth = _doNothingB,
    void Function(R right1, L2 left2) ifRightLeft = _doNothingA,
    void Function(R right1, R2 right2) ifRightRight = _doNothingA,
    void Function(R right1, L2 left2, R2 right2) ifRightBoth = _doNothingB,
    void Function(L left, R right, L2 left2) ifBothLeft = _doNothingB,
    void Function(L left, R right, R2 right2) ifBothRight = _doNothingB,
    void Function(L left, R right, L2 left2, R2 right2) ifBothBoth = _doNothingC,
  }) {
    combineWith(
      other,
      ifLeftLeft: (value1, value2) => () => ifLeftLeft(value1, value2),
      ifLeftRight: (value1, value2) => () => ifLeftRight(value1, value2),
      ifLeftBoth: (value1, left, right) => () => ifLeftBoth(value1, left, right),
      ifRightLeft: (value1, value2) => () => ifRightLeft(value1, value2),
      ifRightRight: (value1, value2) => () => ifRightRight(value1, value2),
      ifRightBoth: (value1, left, right) => () => ifRightBoth(value1, left, right),
      ifBothLeft: (left, right, value) => () => ifBothLeft(left, right, value),
      ifBothRight: (left, right, value) => () => ifBothRight(left, right, value),
      ifBothBoth: (left1, right1, left2, right2) => () => ifBothBoth(left1, right1, left2, right2),
    )();
  }
}
