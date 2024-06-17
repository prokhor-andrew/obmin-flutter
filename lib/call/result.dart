// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.


sealed class Result<Res, Err> {

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
