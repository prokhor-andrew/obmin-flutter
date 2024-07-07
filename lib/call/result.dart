// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/either.dart';

sealed class Result<Res, Err> {
  Either<Res, Err> asEither() {
    switch (this) {
      case Success<Res, Err>(value: final value):
        return Left(value);
      case Failure<Res, Err>(value: final value):
        return Right(value);
    }
  }

  @override
  String toString() {
    switch (this) {
      case Success<Res, Err>(value: var value):
        return "Success<$Res, $Err> { value=$value }";
      case Failure<Res, Err>(value: var value):
        return "Failure<$Res, $Err> { value=$value }";
    }
  }
}

final class Success<Res, Err> extends Result<Res, Err> {
  final Res value;

  Success(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<Res, Err> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

final class Failure<Res, Err> extends Result<Res, Err> {
  final Err value;

  Failure(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<Res, Err> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

extension EitherToResult<Res, Err> on Either<Res, Err> {
  Result<Res, Err> asResult() {
    return fold<Result<Res, Err>>(
      Success.new,
      Failure.new,
    );
  }
}
