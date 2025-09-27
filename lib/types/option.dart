// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/these.dart';
import 'package:obmin/types/validator.dart';

final class Option<T> {
  final Either<(), T> _either;

  const Option._(this._either);

  static Option<A> some<A>(A value) => Option._(Either.right(value));

  static Option<A> none<A>() => Option._(Either.left(()));

  static Option<()> unit() => Option.some(());

  static Option<Never> zero() => Option.none();

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

  Option<(T, R)> zip<R>(Option<R> other) {
    return match(
      Option.none,
      (val1) => other.match(Option.none, (val2) => Option.some((val1, val2))),
    );
  }

  Option<R> bind<R>(Func<T, Option<R>> function) {
    return match(Option.none, function);
  }

  Option<R> rmap<R>(Func<T, R> f) {
    return bind((value) {
      return Option.some(f(value));
    });
  }

  T valueOr(T replacement) {
    return match<T>(
      () => replacement,
      idfunc,
    );
  }

  bool isSome() => rmap(constfunc(true)).valueOr(false);

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

  Option<Either<T, T2>> alt<T2>(Option<T2> other) {
    return match(
      () => other.rmap(Either.right),
      (value) => Option.some(Either.left(value)),
    );
  }

  static Option<IList<Part>> zipAll<Part>(IList<Option<Part>> list) {
    return list.fold(Option.some(const IList.empty()), (current, element) {
      final listInOption = element.rmap((value) => [value].lock);
      return current.zip(listInOption).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static Option<(int, Part)> altAll<Part>(IList<Option<Part>> list) {
    return list.indexed.fold(Option.none(), (current, element) {
      final (index, option) = element;
      final indexedOption = option.rmap((value) => (index, value));
      return current.alt(indexedOption).rmap((either) {
        return either.value();
      });
    });
  }

  Validator<(), T> asValidator() {
    return match(() {
      return Validator.errors<(), T>(const IList.empty());
    }, Validator.of);
  }

  IList<T> asList() {
    return match(() => const IList.empty(), (value) => [value].lock);
  }

  These<(), T> asThese() {
    return match(() => These.left(()), These.right);
  }
}

extension EitherToOptionalExtension<T> on Either<(), T> {
  Option<T> asOption() {
    return match<Option<T>>(
      constfunc(Option.none()),
      Option.some,
    );
  }
}

extension OptionMonadExtension<T> on Option<Option<T>> {
  Option<T> joined() {
    return bind(idfunc);
  }
}
