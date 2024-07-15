// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/either.dart';

sealed class Optional<T> {
  const Optional();

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

  V fold<V>(
    V Function(T value) ifSome,
    V Function() ifNone,
  ) {
    return switch (this) {
      Some<T>(value: final value) => ifSome(value),
      None<T>() => ifNone(),
    };
  }

  T valueOr(T replacement) {
    return fold<T>(
      (val) => val,
      () => replacement,
    );
  }

  T force() {
    return fold<T>(
      (val) => val,
      () => throw "None<$T> is being forcefully unwrapped",
    );
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
    return fold(
      Left.new,
      () => Right(()),
    );
  }

  @override
  String toString() {
    return fold<String>(
      (value) => "Some<$T> { value=$value }",
      () => "None<$T>",
    );
  }
}

final class Some<T> extends Optional<T> {
  final T value;

  const Some(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Some<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

final class None<T> extends Optional<T> {
  const None();

  @override
  bool operator ==(Object other) {
    return other is None<T>;
  }

  @override
  int get hashCode => 0;
}

extension EitherToOptional<T> on Either<T, ()> {
  Optional<T> asOptional() {
    return fold<Optional<T>>(
      Some.new,
      (_) => const None(),
    );
  }
}
