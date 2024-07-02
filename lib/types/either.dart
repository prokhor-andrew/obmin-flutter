// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/product.dart';

sealed class Either<L, R> {
  Either<LeftResult, R> bindLeft<LeftResult>(Either<LeftResult, R> Function(L left) function) {
    return fold<Either<LeftResult, R>>(function, Right.new);
  }

  Either<L, RightResult> bindRight<RightResult>(Either<L, RightResult> Function(R right) function) {
    return swapped().bindLeft<RightResult>((value) {
      return function(value).swapped();
    }).swapped();
  }

  Either<LeftResult, R> mapLeft<LeftResult>(LeftResult Function(L left) function) {
    return bindLeft<LeftResult>((value) {
      return Left(function(value));
    });
  }

  Either<LeftResult, R> mapLeftTo<LeftResult>(LeftResult value) => mapLeft((_) => value);

  Either<L, RightResult> mapRight<RightResult>(RightResult Function(R right) function) {
    return swapped().mapLeft(function).swapped();
  }

  Either<L, RightResult> mapRightTo<RightResult>(RightResult value) => mapRight((_) => value);

  Either<R, L> swapped() {
    return fold<Either<R, L>>(Right.new, Left.new);
  }

  void executeIfLeft(void Function(L value) function) {
    fold<void Function()>(
      (value) => () => function(value),
      (_) => () {},
    )();
  }

  void executeIfRight(void Function(R value) function) {
    swapped().executeIfLeft(function);
  }

  Either<Product<L, T>, Product<R, T>> attach<T>(T value) {
    return mapLeft((left) {
      return Product(left, value);
    }).mapRight((right) {
      return Product(right, value);
    });
  }

  T fold<T>(T Function(L left) ifLeft, T Function(R right) ifRight) {
    return switch (this) {
      Left<L, R>(value: final value) => ifLeft(value),
      Right<L, R>(value: final value) => ifRight(value),
    };
  }

  @override
  String toString() {
    return fold<String>(
      (value) => "Either<$L, $R> Left=$value",
      (value) => "Either<$L, $R> Right=$value",
    );
  }
}

final class Left<L, R> extends Either<L, R> {
  final L value;

  Left(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Left<L, R> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

final class Right<L, R> extends Either<L, R> {
  final R value;

  Right(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Right<L, R> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

extension EitherValueWhenBoth<T> on Either<T, T> {
  T get value => fold<T>(
        (val) => val,
        (val) => val,
      );
}

extension EitherValueWhenLeftNever<T> on Either<Never, T> {
  T get value => fold<T>(
        (never) => throw "Unreachable code is reached", // this code cannot be reached
        (val) => val,
      );
}

extension EitherValueWhenRightNever<T> on Either<T, Never> {
  T get value => swapped().value;
}
