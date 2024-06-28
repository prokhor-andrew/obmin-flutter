// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/either.dart';
import 'package:obmin/a_foundation/types/optional.dart';

sealed class Result<Res, Err> {
  Result<NewRes, Err> mapRes<NewRes>(NewRes Function(Res res) mapper) {
    switch (this) {
      case Success<Res, Err>(result: var value):
        return Success<NewRes, Err>(mapper(value));
      case Failure<Res, Err>(error: var value):
        return Failure<NewRes, Err>(value);
    }
  }

  Result<NewRes, Err> mapResTo<NewRes>(NewRes value) => mapRes((_) => value);

  Result<Res, NewErr> mapError<NewErr>(NewErr Function(Err err) mapper) {
    switch (this) {
      case Success<Res, Err>(result: var value):
        return Success<Res, NewErr>(value);
      case Failure<Res, Err>(error: var value):
        return Failure<Res, NewErr>(mapper(value));
    }
  }

  Result<Res, NewErr> mapErrorTo<NewErr>(NewErr value) => mapError((_) => value);

  Result<C, Err> map<C>(C Function(Res value) function) {
    return mapRes(function);
  }

  Result<C, Err> bind<C>(Result<C, Err> Function(Res value) function) {
    return switch (this) {
      Success<Res, Err>(result: final value) => function(value),
      Failure<Res, Err>(error: final value) => Failure(value),
    };
  }

  Result<Err, Res> swapped() {
    switch (this) {
      case Success<Res, Err>(result: final value):
        return Failure(value);
      case Failure<Res, Err>(error: final value):
        return Success(value);
    }
  }

  Optional<Res> leftOrNone() {
    switch (this) {
      case Success(result: final value):
        return Some(value);
      case Failure():
        return None();
    }
  }

  Optional<Err> rightOrNone() {
    switch (this) {
      case Success():
        return None();
      case Failure(error: final value):
        return Some(value);
    }
  }

  void executeIfSuccess(void Function(Res value) function) {
    switch (this) {
      case Success<Res, Err>(result: final value):
        function(value);
        break;
      case Failure<Res, Err>():
        break;
    }
  }

  void executeIfRight(void Function(Err value) function) {
    switch (this) {
      case Success<Res, Err>():
        break;
      case Failure<Res, Err>(error: final value):
        function(value);
        break;
    }
  }

  Either<Res, Err> asEither() {
    switch (this) {
      case Success<Res, Err>(result: final value):
        return Left(value);
      case Failure<Res, Err>(error: final value):
        return Right(value);
    }
  }
}

final class Success<Res, Err> extends Result<Res, Err> {
  final Res result;

  Success(this.result);

  @override
  String toString() {
    return "Success<$Res, $Err> { result=$result }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Success<Res, Err>) return false;
    return result == other.result;
  }

  @override
  int get hashCode => result.hashCode;
}

final class Failure<Res, Err> extends Result<Res, Err> {
  final Err error;

  Failure(this.error);

  @override
  String toString() {
    return "Failure<$Res, $Err> { error=$error }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Failure<Res, Err>) return false;
    return error == other.error;
  }

  @override
  int get hashCode => error.hashCode;
}
