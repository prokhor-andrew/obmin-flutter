// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/either.dart';

typedef Optional<T> = Either<T, ()>;
typedef Some<T> = Left<T, ()>;
typedef None<T> = Right<T, ()>;

extension OptionalFunctions<T> on Optional<T> {
  Optional<R> map<R>(R Function(T value) function) {
    return mapLeft<R>(function);
  }

  Optional<R> mapTo<R>(R value) {
    return mapLeftTo<R>(value);
  }

  Optional<R> bind<R>(Optional<R> Function(T value) function) {
    return bindLeft<R>(function);
  }

  T valueOr(T replacement) {
    return mapRightTo<T>(replacement).value;
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
    executeIfLeft(function);
  }

  void executeIfNone(void Function() function) {
    executeIfRight((_) {
      function();
    });
  }
}
