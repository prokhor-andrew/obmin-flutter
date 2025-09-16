// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/either.dart';
import 'package:obmin/types/func.dart';

final class Option<T> {
  final Either<(), T> _either;

  const Option._(this._either);

  static Option<A> some<A>(A value) => Option._(Either.right(value));

  static Option<A> none<A>() => Option._(Either.left(()));

  V match<V>(
    V Function() ifNone,
    Func<T, V> ifSome,
  ) {
    return _either.match((_) => ifNone(), ifSome);
  }

  Either<(), T> asEither() {
    return _either;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Option<T>) return false;

    return match(
      () => other.match(() => true, constfunc(false)),
      (val) => other.match(() => false, (val2) => val == val2),
    );
  }

  @override
  int get hashCode => match(() => 0, (val) => val.hashCode);

  Option<(T, R)> zipWith<R>(Option<R> other) {
    return match(
      Option.none,
      (val1) => other.match(Option.none, (val2) => Option.some((val1, val2))),
    );
  }

  Option<R> bind<R>(Func<T, Option<R>> function) {
    return match(Option.none, function);
  }

  Option<R> map<R>(Func<T, R> function) {
    return bind((value) {
      return Option.some(function(value));
    });
  }

  T valueOr(T replacement) {
    return match<T>(
      () => replacement,
      idfunc,
    );
  }

  bool isSome() => map(constfunc(true)).valueOr(false);

  bool isNone() => !isSome();

  void run(void Function() ifNone, void Function(T value) ifSome) {
    match<void Function()>(
        () => ifNone,
        (value) => () {
              ifSome(value);
            })();
  }

  void runIfSome(void Function(T value) function) {
    run(() {}, function);
  }

  void runIfNone(void Function() function) {
    run(function, (_) {});
  }
}

extension EitherToOptionalExtension<T> on Either<(), T> {
  Option<T> asOption() {
    return match<Option<T>>(
      (_) => Option.none(),
      Option.some,
    );
  }
}
