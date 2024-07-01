// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/either.dart';

sealed class Optional<T> {
  Optional<R> bind<R>(Optional<R> Function(T value) function) {
    return asEither().bindLeft<R>((value) {
      return function(value).asEither();
    }).asOptional();
  }

  Optional<R> map<R>(R Function(T value) function) {
    return bind((value) {
      return Some(function(value));
    });
  }

  Optional<R> mapTo<R>(R value) {
    return map<R>((_) => value);
  }

  T valueOr(T replacement) {
    return asEither().mapRightTo<T>(replacement).value;
  }

  T force() {
    switch (this) {
      case None<T>():
        throw "None<$T> is being forcefully unwrapped";
      case Some<T>(value: final value):
        return value;
    }
  }

  void executeIfSome(void Function(T value) function) {
    asEither().executeIfLeft(function);
  }

  void executeIfNone(void Function() function) {
    asEither().executeIfRight((_) {
      function();
    });
  }

  Either<T, ()> asEither() {
    switch (this) {
      case Some<T>(value: final value):
        return Left(value);
      case None<T>():
        return Right(());
    }
  }

  @override
  String toString() {
    return switch (this) {
      None<T>() => "None<$T>",
      Some<T>(value: final value) => "Some<$T> { value=$value }",
    };
  }
}

final class Some<T> extends Optional<T> {
  final T value;

  Some(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Some<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

final class None<T> extends Optional<T> {
  @override
  bool operator ==(Object other) {
    return other is None<T>;
  }

  @override
  int get hashCode => 0;
}

extension EitherToOptional<T> on Either<T, ()> {
  Optional<T> asOptional() {
    switch (this) {
      case Left(value: final value):
        return Some(value);
      case Right():
        return None();
    }
  }
}
