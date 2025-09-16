// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/option.dart';

import 'either.dart';

final class Validator<E, A> {
  final Either<IList<E>, A> _either;

  const Validator._(this._either);

  static Validator<E, A> fromEither<E, A>(Either<IList<E>, A> either) => Validator._(either);

  static Validator<E, A> of<A, E>(A value) => Validator._(Either.right(value));

  static Validator<E, A> error<A, E>(E error) => Validator._(Either.left([error].lock));

  static Validator<E, A> errors<A, E>(IList<E> errors) => Validator._(Either.left(errors));

  T match<T>(
    Func<IList<E>, T> ifErrors,
    Func<A, T> ifValue,
  ) {
    return _either.match(ifErrors, ifValue);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Validator<E, A>) return false;

    return match(
      (errors) => other.match((errors2) => errors == errors2, constant(false)),
      (value) => other.match(constant(false), (value2) => value == value2),
    );
  }

  @override
  int get hashCode => match((value) => value.hashCode, (value) => value.hashCode);

  Validator<T, A> lmap<T>(Func<E, T> function) {
    return match((errors) => Validator.errors(errors.map(function).toIList()), Validator.of);
  }

  Validator<E, T> rmap<T>(Func<A, T> function) {
    return match(Validator.errors, (value) => Validator.of(function(value)));
  }

  Validator<E, T> map<T>(Func<A, T> function) {
    return rmap(function);
  }

  Validator<E, (A, T2)> zipWith<T2>(Validator<E, T2> other) {
    return match((errors) {
      return other.match(
        (errors2) => Validator.errors(errors.addAll(errors2)),
        (_) => Validator.errors(errors),
      );
    }, (value) {
      return other.match(Validator.errors, (value2) {
        return Validator.of((value, value2));
      });
    });
  }

  Option<IList<E>> errorsOrNone() => match<Option<IList<E>>>(
        Option.some,
        constant(Option.none()),
      );

  Option<A> valueOrNone() => match<Option<A>>(
        constant(Option.none()),
        Option.some,
      );

  bool isErrors() => errorsOrNone().map(constant(true)).valueOr(false);

  bool isValue() => !isErrors();

  void run(void Function(IList<E> errors) ifErrors, void Function(A value) ifValue) {
    match<void Function()>(
        (errors) => () {
              ifErrors(errors);
            },
        (value) => () {
              ifValue(value);
            })();
  }

  void runIfErrors(void Function(IList<E> errors) function) {
    run(function, (_) {});
  }

  void runIfValue(void Function(A value) function) {
    run((_) {}, function);
  }

  Either<IList<E>, A> asEither() => _either;
}
