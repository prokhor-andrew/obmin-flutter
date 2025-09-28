// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/logger.dart';
import 'package:obmin/types/option.dart';
import 'package:obmin/types/these.dart';
import 'package:obmin/types/validator.dart';
import 'package:obmin/types/writer.dart';

final class Call<A, B> {
  final Either<A, B> _either;

  const Call._(this._either);

  static Call<A, B> launched<A, B>(A err) => Call._(Either.left(err));

  static Call<A, B> returned<A, B>(B val) => Call._(Either.right(val));

  static Call<A, ()> unit<A>() => Call.returned(());

  T match<T>(Func<A, T> ifLaunched, Func<B, T> ifReturned) {
    return _either.match(ifLaunched, ifReturned);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Call<A, B>) return false;

    return _either == other._either;
  }

  @override
  int get hashCode => _either.hashCode;

  Call<T, B> rescue<T>(Func<A, Call<T, B>> f) {
    return _either.rescue((val) => f(val)._either).asCall();
  }

  Call<T, B> lmap<T>(Func<A, T> f) {
    return _either.lmap(f).asCall();
  }

  Call<A, T> bind<T>(Func<B, Call<A, T>> f) {
    return _either.bind((val) => f(val)._either).asCall();
  }

  Call<A, T> rmap<T>(Func<B, T> f) {
    return _either.rmap(f).asCall();
  }

  Call<A2, B2> bimap<A2, B2>(Func<A, A2> lf, Func<B, B2> rf) {
    return _either.bimap(lf, rf).asCall();
  }

  Call<A, (B, T2)> zip<T2>(Call<A, T2> other) {
    return _either.zip(other._either).asCall();
  }

  Option<A> launchedOrNone() => _either.leftOrNone();

  Option<B> returnedOrNone() => _either.rightOrNone();

  bool isLaunched() => _either.isLeft();

  bool isReturned() => _either.isRight();

  void run(void Function(A value) ifLaunched, void Function(B value) ifReturned) {
    _either.run(ifLaunched, ifReturned);
  }

  void runIfLaunched(void Function(A value) f) {
    _either.runIfLeft(f);
  }

  void runIfReturned(void Function(B value) f) {
    _either.runIfRight(f);
  }

  static Call<E, IList<Part>> zipAll<E, Part>(IList<Call<E, Part>> list) {
    return list.fold(Call.returned(const IList.empty()), (current, element) {
      final call = element.rmap((value) => [value].lock);
      return current.zip(call).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  These<A, B> asThese() {
    return match(These.left, These.right);
  }

  Either<A, B> asEither() {
    return _either;
  }
}

extension CallValueWhenBothExtension<T> on Call<T, T> {
  T value() => match<T>(idfunc, idfunc);

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

extension CallNeverLaunchedExtension<T> on Call<Never, T> {
  T value() => match<T>(absurd, idfunc);

  IList<T> asIList() {
    return [value()].lock;
  }
}

extension CallNeverReturnedExtension<T> on Call<T, Never> {
  T value() => match<T>(idfunc, absurd);
}

extension CallUnitLaunchedExtension<T> on Call<(), T> {
  Option<T> asOption() {
    return match(constfunc(Option.none()), Option.some);
  }

  IList<T> asList() {
    return match(constfunc(const IList.empty()), (value) => [value].lock);
  }
}

extension CallListLaunchedExtension<E, T> on Call<IList<E>, T> {
  Validator<E, T> asValidator() {
    return match(Validator.errors, Validator.of);
  }
}

extension CallMonadExtension<E, T> on Call<E, Call<E, T>> {
  Call<E, T> joined() {
    return bind(idfunc);
  }
}
