// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/product.dart';

sealed class Either<L, R> {
  Either<LeftResult, R> bindLeft<LeftResult>(Either<LeftResult, R> Function(L left) function) {
    return switch (this) {
      Left<L, R>(value: final value) => function(value),
      Right<L, R>(value: final value) => Right(value),
    };
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
    switch (this) {
      case Left<L, R>(value: final value):
        return Right(value);
      case Right<L, R>(value: final value):
        return Left(value);
    }
  }

  void executeIfLeft(void Function(L value) function) {
    switch (this) {
      case Left<L, R>(value: final value):
        function(value);
        break;
      case Right<L, R>():
        break;
    }
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

  @override
  String toString() {
    switch (this) {
      case Left<L, R>(value: var value):
        return "Either<$L, $R> Left=$value";
      case Right<L, R>(value: var value):
        return "Either<$L, $R> Right=$value";
    }
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
  T get value => switch (this) {
        Left<T, T>(value: final value) || Right<T, T>(value: final value) => value,
      };
}

extension EitherValueWhenLeftNever<T> on Either<Never, T> {
  T get value => switch (this) {
        Left<Never, T>() => throw "Unreachable code is reached", // this code cannot be reached
        Right<Never, T>(value: final value) => value,
      };
}

extension EitherValueWhenRightNever<T> on Either<T, Never> {
  T get value => swapped().value;
}
