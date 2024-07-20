// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

sealed class Result<Res, Err> {
  const Result();

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

  const Success(this.value);

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

  const Failure(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<Res, Err> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
