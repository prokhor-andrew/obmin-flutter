// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/bidirect/bi_preview.dart';
import 'package:obmin/optics/bidirect/iso.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/bidirect/prism.dart';
import 'package:obmin/optics/bidirect/reflector.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/utils/bool_fold.dart';

final class Optional<T> {
  final bool _isSome;
  final T? _value;

  const Optional.some(T value)
      : _value = value,
        _isSome = true;

  const Optional.none()
      : _value = null,
        _isSome = false;

  V fold<V>(
    V Function(T value) ifSome,
    V Function() ifNone,
  ) {
    return _isSome.fold<V>(
      () => ifSome(_value!),
      ifNone,
    );
  }

  Either<T, ()> asEither() {
    return fold(
      Either<T, ()>.left,
      () => Either<T, ()>.right(()),
    );
  }

  @override
  String toString() {
    return fold<String>(
      (value) => "Some<$T> { value=$value }",
      () => "None<$T>",
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Optional<T>) return false;

    if (_isSome != other._isSome) return false;

    if (_isSome) return _value == other._value;

    return true;
  }

  @override
  int get hashCode => _isSome ? _value.hashCode : 0;

  Optional<R> bind<R>(Optional<R> Function(T value) function) {
    return asEither().bindLeft<R>((value) {
      return function(value).asEither();
    }).asOptional();
  }

  Optional<R> map<R>(R Function(T value) function) {
    return bind((value) {
      return Optional<R>.some(function(value));
    });
  }

  Optional<R> mapTo<R>(R value) {
    return map<R>((_) => value);
  }

  T valueOr(T replacement) {
    return fold<T>(
      (val) => val,
      () => replacement,
    );
  }

  bool get isSome => mapTo(true).valueOr(false);

  bool get isNone => !isSome;

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

  static Eqv<Optional<T>> eqv<T>() => Eqv<Optional<T>>();

  static Mutator<Optional<T>, Optional<T>> reducer<T>() => Mutator.reducer<Optional<T>>();
}

extension EitherToOptionalExtension<T> on Either<T, ()> {
  Optional<T> asOptional() {
    return fold<Optional<T>>(
      Optional<T>.some,
      (_) => Optional.none(),
    );
  }
}

extension OptionalObminOpticEqvExtension<T> on Eqv<Optional<T>> {
  Preview<Optional<T>, T> get value => Preview<Optional<T>, T>((whole) => whole);
}

extension OptionalObminOpticGetterExtension<Whole, T> on Getter<Whole, Optional<T>> {
  Preview<Whole, T> get value => composeWithPreview(Preview<Optional<T>, T>((whole) => whole));
}

extension OptionalObminOpticPreviewExtension<Whole, T> on Preview<Whole, Optional<T>> {
  Preview<Whole, T> get value => compose(Preview<Optional<T>, T>((whole) => whole));
}

extension OptionalObminOpticFoldExtension<Whole, T> on Fold<Whole, Optional<T>> {
  Fold<Whole, T> get value => composeWithPreview(Preview<Optional<T>, T>((whole) => whole));
}

extension OptionalObminOpticMutatorExtension<Whole, T> on Mutator<Whole, Optional<T>> {
  Mutator<Whole, T> get value => composeWithPrism(
        Prism<Optional<T>, T>(
          Preview<Optional<T>, T>((whole) => whole),
          Getter<T, Optional<T>>(Optional<T>.some),
        ),
      );
}

extension OptionalObminOpticIsoExtension<Whole, T> on Iso<Whole, Optional<T>> {
  Prism<Whole, T> get value => composeWithPrism(
        Prism<Optional<T>, T>(
          Preview<Optional<T>, T>((whole) => whole),
          Getter<T, Optional<T>>(Optional<T>.some),
        ),
      );
}

extension OptionalObminOpticPrismExtension<Whole, T> on Prism<Whole, Optional<T>> {
  Prism<Whole, T> get value => compose(
        Prism<Optional<T>, T>(
          Preview<Optional<T>, T>((whole) => whole),
          Getter<T, Optional<T>>(Optional<T>.some),
        ),
      );
}

extension OptionalObminOpticReflectorExtension<Whole, T> on Reflector<Whole, Optional<T>> {
  BiPreview<Whole, T> get value => composeWithPrism(
        Prism<Optional<T>, T>(
          Preview<Optional<T>, T>((whole) => whole),
          Getter<T, Optional<T>>(Optional<T>.some),
        ),
      );
}

extension OptionalObminOpticBiPreviewExtension<Whole, T> on BiPreview<Whole, Optional<T>> {
  BiPreview<Whole, T> get value => composeWithPrism(
        Prism<Optional<T>, T>(
          Preview<Optional<T>, T>((whole) => whole),
          Getter<T, Optional<T>>(Optional<T>.some),
        ),
      );
}
