// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/eqv.dart';
import 'package:obmin/optics/fold.dart';
import 'package:obmin/optics/getter.dart';
import 'package:obmin/optics/mutable/bi_preview.dart';
import 'package:obmin/optics/mutable/iso.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/mutable/prism.dart';
import 'package:obmin/optics/mutable/reflector.dart';
import 'package:obmin/optics/preview.dart';
import 'package:obmin/types/either.dart';

sealed class Optional<T> {
  const Optional();

  static Eqv<Optional<T>> eqv<T>() => Eqv<Optional<T>>();

  static Mutator<Optional<T>, Optional<T>> setter<T>() => Mutator.setter<Optional<T>>();

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

  static Eqv<Some<T>> eqv<T>() => Eqv<Some<T>>();

  static Mutator<Some<T>, Some<T>> setter<T>() => Mutator.setter<Some<T>>();

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

extension SomeObminOpticEqvExtension<T> on Eqv<Some<T>> {
  Getter<Some<T>, T> get value => asGetter().value;
}

extension SomeObminOpticGetterExtension<Whole, T> on Getter<Whole, Some<T>> {
  Getter<Whole, T> get value => compose(Getter<Some<T>, T>((whole) => whole.value));
}

extension SomeObminOpticPreviewExtension<Whole, T> on Preview<Whole, Some<T>> {
  Preview<Whole, T> get value => composeWithGetter(Getter<Some<T>, T>((whole) => whole.value));
}

extension SomeObminOpticFoldExtension<Whole, T> on Fold<Whole, Some<T>> {
  Fold<Whole, T> get value => composeWithGetter(Getter<Some<T>, T>((whole) => whole.value));
}

extension SomeObminOpticMutatorExtension<Whole, T> on Mutator<Whole, Some<T>> {
  Mutator<Whole, T> get value => compose(
        Mutator.lens<Some<T>, T>(
          Getter<Some<T>, T>((whole) => whole.value),
          (whole, part) => Some(part),
        ),
      );
}

extension SomeObminOpticIsoExtension<Whole, T> on Iso<Whole, Some<T>> {
  Mutator<Whole, T> get value => asMutator().compose(
        Mutator.lens<Some<T>, T>(
          Getter<Some<T>, T>((whole) => whole.value),
          (whole, part) => Some(part),
        ),
      );
}

extension SomeObminOpticPrismExtension<Whole, T> on Prism<Whole, Some<T>> {
  Mutator<Whole, T> get value => asMutator().compose(
        Mutator.lens<Some<T>, T>(
          Getter<Some<T>, T>((whole) => whole.value),
          (whole, part) => Some(part),
        ),
      );
}

extension SomeObminOpticReflectorExtension<Whole, T> on Reflector<Whole, Some<T>> {
  Mutator<Whole, T> get value => asMutator().compose(
        Mutator.lens<Some<T>, T>(
          Getter<Some<T>, T>((whole) => whole.value),
          (whole, part) => Some(part),
        ),
      );
}

extension SomeObminOpticBiPreviewExtension<Whole, T> on BiPreview<Whole, Some<T>> {
  Mutator<Whole, T> get value => asMutator().compose(
        Mutator.lens<Some<T>, T>(
          Getter<Some<T>, T>((whole) => whole.value),
          (whole, part) => Some(part),
        ),
      );
}

extension OptionalObminOpticToolMethodsExtension<T> on Optional<T> {
  Optional<T> mapSome(Some<T> Function(Some<T> value) function) {
    return fold<Optional<T>>(
      ifSome: function,
      ifNone: (val) => val,
    );
  }

  Optional<T> mapSomeTo(Some<T> value) {
    return mapSome((_) => value);
  }

  Optional<T> bindSome(Optional<T> Function(Some<T> value) function) {
    return fold<Optional<T>>(
      ifSome: function,
      ifNone: (val) => val,
    );
  }

  Optional<Some<T>> get someOrNone => fold<Optional<Some<T>>>(
        ifSome: Some.new,
        ifNone: (_) => const None(),
      );

  void executeIfSome(void Function(Some<T> value) function) {
    fold<void Function()>(
      ifSome: (value) => () => function(value),
      ifNone: (_) => () {},
    )();
  }

  Optional<T> mapNone(None<T> Function(None<T> value) function) {
    return fold<Optional<T>>(
      ifSome: (val) => val,
      ifNone: function,
    );
  }

  Optional<T> mapNoneTo(None<T> value) {
    return mapNone((_) => value);
  }

  Optional<T> bindNone(Optional<T> Function(None<T> value) function) {
    return fold<Optional<T>>(
      ifSome: (val) => val,
      ifNone: function,
    );
  }

  Optional<None<T>> get noneOrNone => fold<Optional<None<T>>>(
        ifSome: (_) => const None(),
        ifNone: Some.new,
      );

  void executeIfNone(void Function(None<T> value) function) {
    fold<void Function()>(
      ifSome: (_) => () {},
      ifNone: (value) => () => function(value),
    )();
  }

  R fold<R>({
    required R Function(Some<T> value) ifSome,
    required R Function(None<T> value) ifNone,
  }) {
    final value = this;
    return switch (value) {
      Some<T>() => ifSome(value),
      None<T>() => ifNone(value),
    };
  }
}

extension OptionalObminOpticEqvExtension<T> on Eqv<Optional<T>> {
  Preview<Optional<T>, Some<T>> get some => Preview<Optional<T>, Some<T>>((whole) => whole.someOrNone);

  Preview<Optional<T>, None<T>> get none => Preview<Optional<T>, None<T>>((whole) => whole.noneOrNone);
}

extension OptionalObminOpticGetterExtension<Whole, T> on Getter<Whole, Optional<T>> {
  Preview<Whole, Some<T>> get some => composeWithPreview(Preview<Optional<T>, Some<T>>((whole) => whole.someOrNone));

  Preview<Whole, None<T>> get none => composeWithPreview(Preview<Optional<T>, None<T>>((whole) => whole.noneOrNone));
}

extension OptionalObminOpticPreviewExtension<Whole, T> on Preview<Whole, Optional<T>> {
  Preview<Whole, Some<T>> get some => compose(Preview<Optional<T>, Some<T>>((whole) => whole.someOrNone));

  Preview<Whole, None<T>> get none => compose(Preview<Optional<T>, None<T>>((whole) => whole.noneOrNone));
}

extension OptionalObminOpticFoldExtension<Whole, T> on Fold<Whole, Optional<T>> {
  Fold<Whole, Some<T>> get some => composeWithPreview(Preview<Optional<T>, Some<T>>((whole) => whole.someOrNone));

  Fold<Whole, None<T>> get none => composeWithPreview(Preview<Optional<T>, None<T>>((whole) => whole.noneOrNone));
}

extension OptionalObminOpticMutatorExtension<Whole, T> on Mutator<Whole, Optional<T>> {
  Mutator<Whole, Some<T>> get some => composeWithPrism(
        Prism<Optional<T>, Some<T>>(
          Preview<Optional<T>, Some<T>>((whole) => whole.someOrNone),
          Getter<Some<T>, Optional<T>>((part) => part),
        ),
      );

  Mutator<Whole, None<T>> get none => composeWithPrism(
        Prism<Optional<T>, None<T>>(
          Preview<Optional<T>, None<T>>((whole) => whole.noneOrNone),
          Getter<None<T>, Optional<T>>((part) => part),
        ),
      );
}

extension OptionalObminOpticIsoExtension<Whole, T> on Iso<Whole, Optional<T>> {
  Prism<Whole, Some<T>> get some => composeWithPrism(
        Prism<Optional<T>, Some<T>>(
          Preview<Optional<T>, Some<T>>((whole) => whole.someOrNone),
          Getter<Some<T>, Optional<T>>((part) => part),
        ),
      );

  Prism<Whole, None<T>> get none => composeWithPrism(
        Prism<Optional<T>, None<T>>(
          Preview<Optional<T>, None<T>>((whole) => whole.noneOrNone),
          Getter<None<T>, Optional<T>>((part) => part),
        ),
      );
}

extension OptionalObminOpticPrismExtension<Whole, T> on Prism<Whole, Optional<T>> {
  Prism<Whole, Some<T>> get some => compose(
        Prism<Optional<T>, Some<T>>(
          Preview<Optional<T>, Some<T>>((whole) => whole.someOrNone),
          Getter<Some<T>, Optional<T>>((part) => part),
        ),
      );

  Prism<Whole, None<T>> get none => compose(
        Prism<Optional<T>, None<T>>(
          Preview<Optional<T>, None<T>>((whole) => whole.noneOrNone),
          Getter<None<T>, Optional<T>>((part) => part),
        ),
      );
}

extension OptionalObminOpticReflectorExtension<Whole, T> on Reflector<Whole, Optional<T>> {
  BiPreview<Whole, Some<T>> get some => composeWithPrism(
        Prism<Optional<T>, Some<T>>(
          Preview<Optional<T>, Some<T>>((whole) => whole.someOrNone),
          Getter<Some<T>, Optional<T>>((part) => part),
        ),
      );

  BiPreview<Whole, None<T>> get none => composeWithPrism(
        Prism<Optional<T>, None<T>>(
          Preview<Optional<T>, None<T>>((whole) => whole.noneOrNone),
          Getter<None<T>, Optional<T>>((part) => part),
        ),
      );
}

extension OptionalObminOpticBiPreviewExtension<Whole, T> on BiPreview<Whole, Optional<T>> {
  BiPreview<Whole, Some<T>> get some => composeWithPrism(
        Prism<Optional<T>, Some<T>>(
          Preview<Optional<T>, Some<T>>((whole) => whole.someOrNone),
          Getter<Some<T>, Optional<T>>((part) => part),
        ),
      );

  BiPreview<Whole, None<T>> get none => composeWithPrism(
        Prism<Optional<T>, None<T>>(
          Preview<Optional<T>, None<T>>((whole) => whole.noneOrNone),
          Getter<None<T>, Optional<T>>((part) => part),
        ),
      );
}
