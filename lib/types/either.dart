// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/call.dart';
import 'package:obmin/types/flist.dart';
import 'package:obmin/types/logger.dart';
import 'package:obmin/types/option.dart';
import 'package:obmin/types/result.dart';
import 'package:obmin/types/these.dart';
import 'package:obmin/types/validator.dart';
import 'package:obmin/types/writer.dart';

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

  static Either<A, ()> unit<A>() => Either.right(());

  T match<T>(
    Func<A, T> ifLeft,
    Func<B, T> ifRight,
  ) {
    return _isRight ? ifRight(_right as B) : ifLeft(_left as A);
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

  Either<A, (B, T2)> zip<T2>(Either<A, T2> other) {
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

  bool isLeft() => leftOrNone().rmap(constfunc(true)).valueOr(false);

  bool isRight() => !isLeft();

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

  static Either<E, IList<Part>> zipAll<E, Part>(IList<Either<E, Part>> list) {
    return list.fold(Either.right(const IList.empty()), (current, element) {
      final either = element.rmap((value) => [value].lock);
      return current.zip(either).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  These<A, B> asThese() {
    return match(These.left, These.right);
  }

  Result<A, B> asResult() {
    return match(Result.failure, Result.success);
  }

  Call<A, B> asCall() {
    return match(Call.launched, Call.returned);
  }
}

extension EitherValueWhenBothExtension<T> on Either<T, T> {
  T value() => match<T>(idfunc, idfunc);

  FList<T> asFList() {
    return FList(value());
  }

  IList<T> asIList() {
    return [value()].lock;
  }

  Logger<T> asLogger() {
    return Logger.of(value());
  }

  Writer<E, T> asWriter<E>() {
    return Writer.of(value());
  }
}

extension EitherNeverLeftExtension<T> on Either<Never, T> {
  T value() => match<T>(absurd, idfunc);

  FList<T> asFList() {
    return FList(value());
  }

  IList<T> asIList() {
    return [value()].lock;
  }
}

extension EitherNeverRightExtension<T> on Either<T, Never> {
  T value() => match<T>(idfunc, absurd);
}

extension EitherUnitLeftExtension<T> on Either<(), T> {
  Option<T> asOption() {
    return match(constfunc(Option.none()), Option.some);
  }

  IList<T> asList() {
    return match(constfunc(const IList.empty()), (value) => [value].lock);
  }
}

extension EitherListLeftExtension<E, T> on Either<IList<E>, T> {
  Validator<E, T> asValidator() {
    return match(Validator.errors, Validator.of);
  }
}

extension EitherMonadExtension<E, T> on Either<E, Either<E, T>> {
  Either<E, T> joined() {
    return bind(idfunc);
  }
}
