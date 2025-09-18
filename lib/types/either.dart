// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/func.dart';
import 'package:obmin/types/option.dart';

typedef Call<Req, Res> = Either<Req, Res>;
typedef Result<Err, Val> = Either<Err, Val>;

final class Either<A, B> {
  final bool _isRight;
  final A? _left;
  final B? _right;

  const Either._left(A left)
      : _left = left,
        _right = null,
        _isRight = false;

  const Either._right(B right)
      : _right = right,
        _left = null,
        _isRight = true;

  static Either<A, B> left<A, B>(A value) => Either._left(value);

  static Either<A, B> right<A, B>(B value) => Either._right(value);

  static Either<A, B> launched<A, B>(A req) => Either.left(req);

  static Either<A, B> returned<A, B>(B res) => Either.right(res);

  static Either<A, B> failure<A, B>(A err) => Either.left(err);

  static Either<A, B> success<A, B>(B val) => Either.right(val);

  T match<T>(
    Func<A, T> ifLeft,
    Func<B, T> ifRight,
  ) {
    return _isRight ? ifLeft(_left as A) : ifRight(_right as B);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Either<A, B>) return false;

    return match(
      (left1) => other.match((left2) => left1 == left2, constfunc(false)),
      (right1) => other.match(constfunc(false), (right2) => right1 == right2),
    );
  }

  @override
  int get hashCode => match((value) => value.hashCode, (value) => value.hashCode);

  Either<B, A> swapped() {
    return match<Either<B, A>>(
      Either.right,
      Either.left,
    );
  }

  Either<T, B> rescue<T>(Func<A, Either<T, B>> function) {
    return match<Either<T, B>>(
      function,
      Either.right,
    );
  }

  Either<T, B> lmap<T>(Func<A, T> f) {
    return swapped().rmap(f).swapped();
  }

  Either<A, T> bind<T>(Func<B, Either<A, T>> function) {
    return match<Either<A, T>>(
      Either.left,
      function,
    );
  }

  Either<A, T> rmap<T>(Func<B, T> function) {
    return swapped().lmap<T>(function).swapped();
  }

  Either<A2, B2> bimap<A2, B2>(Func<A, A2> lf, Func<B, B2> rf) {
    return lmap(lf).rmap(rf);
  }

  Either<A, (B, T2)> zipWith<T2>(Either<A, T2> other) {
    return match(
      Either.left,
      (val1) => other.match(Either.left, (val2) => Either.right((val1, val2))),
    );
  }

  Option<A> leftOrNone() => match<Option<A>>(
        Option.some,
        constfunc(Option.none()),
      );

  Option<B> rightOrNone() => swapped().leftOrNone();

  Option<A> launchedOrNone() => leftOrNone();

  Option<B> returnedOrNone() => rightOrNone();

  Option<A> failureOrNone() => leftOrNone();

  Option<B> successOrNone() => rightOrNone();

  bool isLeft() => leftOrNone().rmap(constfunc(true)).valueOr(false);

  bool isRight() => !isLeft();

  bool isLaunched() => isLeft();

  bool isReturned() => isRight();

  bool isFailure() => isLeft();

  bool isSuccess() => isRight();

  void run(void Function(A value) ifLeft, void Function(B value) ifRight) {
    match<void Function()>(
        (value) => () {
              ifLeft(value);
            },
        (value) => () {
              ifRight(value);
            })();
  }

  void runIfLeft(void Function(A value) function) {
    run(function, (_) {});
  }

  void runIfRight(void Function(B value) function) {
    swapped().runIfLeft(function);
  }

  void runIfLaunched(void Function(A value) f) {
    runIfLeft(f);
  }

  void runIfReturned(void Function(B value) f) {
    runIfRight(f);
  }

  void runIfFailure(void Function(A value) f) {
    runIfLeft(f);
  }

  void runIfSuccess(void Function(B value) f) {
    runIfRight(f);
  }
}

extension EitherValueWhenBothExtension<T> on Either<T, T> {
  T value() => match<T>(idfunc, idfunc);
}

extension EitherNeverLeftExtension<T> on Either<Never, T> {
  T value() => match<T>(absurd, idfunc);
}

extension EitherNeverRightExtension<T> on Either<T, Never> {
  T value() => match<T>(idfunc, absurd);
}
