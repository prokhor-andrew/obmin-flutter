// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/either.dart';
import 'package:obmin/types/optional.dart';
import 'package:obmin/types/product.dart';

final class ZipElement<T1, T2> {
  final T1? _left;
  final T2? _right;
  final bool? _isLeft;

  const ZipElement.left(T1 value)
      : _left = value,
        _right = null,
        _isLeft = true;

  const ZipElement.right(T2 value)
      : _left = null,
        _right = value,
        _isLeft = false;

  const ZipElement.both(T1 value1, T2 value2)
      : _left = value1,
        _right = value2,
        _isLeft = null;

  R fold<R>(
    R Function(T1 value) ifLeft,
    R Function(T2 value) ifRight,
    R Function(T1 left, T2 right) ifBoth,
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

  bool get isBoth => fold(
        (_) => false,
        (_) => false,
        (_, __) => true,
      );

  bool get isLeft => fold(
        (_) => true,
        (_) => false,
        (_, __) => false,
      );

  bool get isRight => fold(
        (_) => false,
        (_) => true,
        (_, __) => false,
      );

  Optional<T1> get leftOrNone => fold(
        Optional.some,
        (_) => Optional.none(),
        (value, _) => Optional.some(value),
      );

  Optional<T1> get onlyLeftOrNone => fold(
        Optional.some,
        (_) => Optional.none(),
        (_, __) => Optional.none(),
      );

  Optional<T2> get rightOrNone => swapped.leftOrNone;

  Optional<T2> get onlyRightOrNone => swapped.onlyLeftOrNone;

  Optional<Product<T1, T2>> get bothOrNone => fold(
        (_) => Optional.none(),
        (_) => Optional.none(),
        (left, right) => Optional.some(
          Product(left, right),
        ),
      );

  Optional<Either<T1, T2>> get eitherOrNone => fold(
        (value) => Optional.some(Either.left(value)),
        (value) => Optional.some(Either.right(value)),
        (_, __) => Optional.none(),
      );

  ZipElement<T2, T1> get swapped => fold(
        ZipElement.right,
        ZipElement.left,
        (left, right) => ZipElement.both(right, left),
      );

  ZipElement<V, T2> mapLeft<V>(V Function(T1 value) function) {
    return fold(
      (value) => ZipElement.left(function(value)),
      ZipElement.right,
      (left, right) => ZipElement.both(function(left), right),
    );
  }

  ZipElement<T1, V> mapRight<V>(V Function(T2 value) function) {
    return swapped.mapLeft(function).swapped;
  }

  ZipElement<V1, V2> biMap<V1, V2>(
    V1 Function(T1 value) leftMap,
    V2 Function(T2 value) rightMap,
  ) {
    return mapLeft(leftMap).mapRight(rightMap);
  }

  @override
  String toString() {
    return fold(
      (value) => "ZipElement.left<$T1, $T2> { left=$value }",
      (value) => "ZipElement.right<$T1, $T2> { right=$value }",
      (left, right) => "ZipElement.both<$T1, $T2> { left=$left, right=$right }",
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ZipElement<T1, T2>) return false;

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

  @override
  int get hashCode => fold(
        (value) => value.hashCode,
        (value) => value.hashCode,
        (left, right) => left.hashCode ^ right.hashCode,
      );
}
