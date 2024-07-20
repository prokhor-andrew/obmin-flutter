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
import 'package:obmin/types/optional.dart';
import 'package:obmin/types/product.dart';

sealed class Either<L, R> {
  const Either();

  static Eqv<Either<L, R>> eqv<L, R>() => Eqv<Either<L, R>>();

  static Mutator<Either<L, R>, Either<L, R>> setter<L, R>() => Mutator.setter<Either<L, R>>();

  Optional<L> get leftOrNone => fold<Optional<L>>(
        Some.new,
        (_) => const None(),
      );

  Optional<R> get rightOrNone => fold<Optional<R>>(
        (_) => const None(),
        Some.new,
      );

  Either<LeftResult, R> bindLeft<LeftResult>(Either<LeftResult, R> Function(L left) function) {
    return fold<Either<LeftResult, R>>(function, Right.new);
  }

  Either<L, RightResult> bindRight<RightResult>(Either<L, RightResult> Function(R right) function) {
    return swapped().bindLeft<RightResult>((value) {
      return function(value).swapped();
    }).swapped();
  }

  Either<LeftResult, R> mapLeft<LeftResult>(LeftResult Function(L left) function) {
    return bindLeft<LeftResult>((value) {
      return Left(function(value));
    });
  }

  Either<LeftResult, R> mapLeftTo<LeftResult>(LeftResult value) => mapLeft((_) => value);

  Either<L, RightResult> mapRight<RightResult>(RightResult Function(R right) function) {
    return swapped().mapLeft(function).swapped();
  }

  Either<L, RightResult> mapRightTo<RightResult>(RightResult value) => mapRight((_) => value);

  Either<R, L> swapped() {
    return fold<Either<R, L>>(Right.new, Left.new);
  }

  void executeIfLeft(void Function(L value) function) {
    fold<void Function()>(
      (value) => () => function(value),
      (_) => () {},
    )();
  }

  void executeIfRight(void Function(R value) function) {
    swapped().executeIfLeft(function);
  }

  Either<Product<L, T>, Product<R, T>> attach<T>(T value) {
    return mapLeft((left) {
      return Product(left, value);
    }).mapRight((right) {
      return Product(right, value);
    });
  }

  T fold<T>(T Function(L left) ifLeft, T Function(R right) ifRight) {
    return switch (this) {
      Left<L, R>(value: final value) => ifLeft(value),
      Right<L, R>(value: final value) => ifRight(value),
    };
  }

  @override
  String toString() {
    return fold<String>(
      (value) => "Either<$L, $R> Left=$value",
      (value) => "Either<$L, $R> Right=$value",
    );
  }
}

final class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Left<L, R> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  static Eqv<Left<L, R>> eqv<L, R>() => Eqv<Left<L, R>>();

  static Mutator<Left<L, R>, Left<L, R>> setter<L, R>() => Mutator.setter<Left<L, R>>();
}

final class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Right<L, R> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  static Eqv<Right<L, R>> eqv<L, R>() => Eqv<Right<L, R>>();

  static Mutator<Right<L, R>, Right<L, R>> setter<L, R>() => Mutator.setter<Right<L, R>>();
}

extension EitherValueWhenBoth<T> on Either<T, T> {
  T get value => fold<T>(
        (val) => val,
        (val) => val,
      );
}

extension EitherValueWhenLeftNever<T> on Either<Never, T> {
  T get value => fold<T>(
        (never) => throw "Unreachable code is reached", // this code cannot be reached
        (val) => val,
      );
}

extension EitherValueWhenRightNever<T> on Either<T, Never> {
  T get value => swapped().value;
}

extension LeftObminOpticEqvExtension<L, R> on Eqv<Left<L, R>> {
  Getter<Left<L, R>, L> get value => asGetter().value;
}

extension LeftObminOpticGetterExtension<Whole, L, R> on Getter<Whole, Left<L, R>> {
  Getter<Whole, L> get value => compose(Getter<Left<L, R>, L>((whole) => whole.value));
}

extension LeftObminOpticPreviewExtension<Whole, L, R> on Preview<Whole, Left<L, R>> {
  Preview<Whole, L> get value => composeWithGetter(Getter<Left<L, R>, L>((whole) => whole.value));
}

extension LeftObminOpticFoldExtension<Whole, L, R> on Fold<Whole, Left<L, R>> {
  Fold<Whole, L> get value => composeWithGetter(Getter<Left<L, R>, L>((whole) => whole.value));
}

extension LeftObminOpticMutatorExtension<Whole, L, R> on Mutator<Whole, Left<L, R>> {
  Mutator<Whole, L> get value => compose(
        Mutator.lens<Left<L, R>, L>(
          Getter<Left<L, R>, L>((whole) => whole.value),
          (whole, part) => Left(part),
        ),
      );
}

extension LeftObminOpticIsoExtension<Whole, L, R> on Iso<Whole, Left<L, R>> {
  Mutator<Whole, L> get value => asMutator().compose(
        Mutator.lens<Left<L, R>, L>(
          Getter<Left<L, R>, L>((whole) => whole.value),
          (whole, part) => Left(part),
        ),
      );
}

extension LeftObminOpticPrismExtension<Whole, L, R> on Prism<Whole, Left<L, R>> {
  Mutator<Whole, L> get value => asMutator().compose(
        Mutator.lens<Left<L, R>, L>(
          Getter<Left<L, R>, L>((whole) => whole.value),
          (whole, part) => Left(part),
        ),
      );
}

extension LeftObminOpticReflectorExtension<Whole, L, R> on Reflector<Whole, Left<L, R>> {
  Mutator<Whole, L> get value => asMutator().compose(
        Mutator.lens<Left<L, R>, L>(
          Getter<Left<L, R>, L>((whole) => whole.value),
          (whole, part) => Left(part),
        ),
      );
}

extension LeftObminOpticBiPreviewExtension<Whole, L, R> on BiPreview<Whole, Left<L, R>> {
  Mutator<Whole, L> get value => asMutator().compose(
        Mutator.lens<Left<L, R>, L>(
          Getter<Left<L, R>, L>((whole) => whole.value),
          (whole, part) => Left(part),
        ),
      );
}

extension RightObminOpticEqvExtension<L, R> on Eqv<Right<L, R>> {
  Getter<Right<L, R>, R> get value => asGetter().value;
}

extension RightObminOpticGetterExtension<Whole, L, R> on Getter<Whole, Right<L, R>> {
  Getter<Whole, R> get value => compose(Getter<Right<L, R>, R>((whole) => whole.value));
}

extension RightObminOpticPreviewExtension<Whole, L, R> on Preview<Whole, Right<L, R>> {
  Preview<Whole, R> get value => composeWithGetter(Getter<Right<L, R>, R>((whole) => whole.value));
}

extension RightObminOpticFoldExtension<Whole, L, R> on Fold<Whole, Right<L, R>> {
  Fold<Whole, R> get value => composeWithGetter(Getter<Right<L, R>, R>((whole) => whole.value));
}

extension RightObminOpticMutatorExtension<Whole, L, R> on Mutator<Whole, Right<L, R>> {
  Mutator<Whole, R> get value => compose(
        Mutator.lens<Right<L, R>, R>(
          Getter<Right<L, R>, R>((whole) => whole.value),
          (whole, part) => Right(part),
        ),
      );
}

extension RightObminOpticIsoExtension<Whole, L, R> on Iso<Whole, Right<L, R>> {
  Mutator<Whole, R> get value => asMutator().compose(
        Mutator.lens<Right<L, R>, R>(
          Getter<Right<L, R>, R>((whole) => whole.value),
          (whole, part) => Right(part),
        ),
      );
}

extension RightObminOpticPrismExtension<Whole, L, R> on Prism<Whole, Right<L, R>> {
  Mutator<Whole, R> get value => asMutator().compose(
        Mutator.lens<Right<L, R>, R>(
          Getter<Right<L, R>, R>((whole) => whole.value),
          (whole, part) => Right(part),
        ),
      );
}

extension RightObminOpticReflectorExtension<Whole, L, R> on Reflector<Whole, Right<L, R>> {
  Mutator<Whole, R> get value => asMutator().compose(
        Mutator.lens<Right<L, R>, R>(
          Getter<Right<L, R>, R>((whole) => whole.value),
          (whole, part) => Right(part),
        ),
      );
}

extension RightObminOpticBiPreviewExtension<Whole, L, R> on BiPreview<Whole, Right<L, R>> {
  Mutator<Whole, R> get value => asMutator().compose(
        Mutator.lens<Right<L, R>, R>(
          Getter<Right<L, R>, R>((whole) => whole.value),
          (whole, part) => Right(part),
        ),
      );
}

extension EitherObminOpticEqvExtension<L, R> on Eqv<Either<L, R>> {
  Preview<Either<L, R>, Left<L, R>> get left => Preview<Either<L, R>, Left<L, R>>((whole) => whole.leftOrNone.map(Left.new));

  Preview<Either<L, R>, Right<L, R>> get right => Preview<Either<L, R>, Right<L, R>>((whole) => whole.rightOrNone.map(Right.new));
}

extension EitherObminOpticGetterExtension<Whole, L, R> on Getter<Whole, Either<L, R>> {
  Preview<Whole, Left<L, R>> get left => composeWithPreview(Preview<Either<L, R>, Left<L, R>>((whole) => whole.leftOrNone.map(Left.new)));

  Preview<Whole, Right<L, R>> get right => composeWithPreview(Preview<Either<L, R>, Right<L, R>>((whole) => whole.rightOrNone.map(Right.new)));
}

extension EitherObminOpticPreviewExtension<Whole, L, R> on Preview<Whole, Either<L, R>> {
  Preview<Whole, Left<L, R>> get left => compose(Preview<Either<L, R>, Left<L, R>>((whole) => whole.leftOrNone.map(Left.new)));

  Preview<Whole, Right<L, R>> get right => compose(Preview<Either<L, R>, Right<L, R>>((whole) => whole.rightOrNone.map(Right.new)));
}

extension EitherObminOpticFoldExtension<Whole, L, R> on Fold<Whole, Either<L, R>> {
  Fold<Whole, Left<L, R>> get left => composeWithPreview(Preview<Either<L, R>, Left<L, R>>((whole) => whole.leftOrNone.map(Left.new)));

  Fold<Whole, Right<L, R>> get right => composeWithPreview(Preview<Either<L, R>, Right<L, R>>((whole) => whole.rightOrNone.map(Right.new)));
}

extension EitherObminOpticMutatorExtension<Whole, L, R> on Mutator<Whole, Either<L, R>> {
  Mutator<Whole, Left<L, R>> get left => composeWithPrism(
        Prism<Either<L, R>, Left<L, R>>(
          Preview<Either<L, R>, Left<L, R>>((whole) => whole.leftOrNone.map(Left.new)),
          Getter<Left<L, R>, Either<L, R>>((part) => part),
        ),
      );

  Mutator<Whole, Right<L, R>> get right => composeWithPrism(
        Prism<Either<L, R>, Right<L, R>>(
          Preview<Either<L, R>, Right<L, R>>((whole) => whole.rightOrNone.map(Right.new)),
          Getter<Right<L, R>, Either<L, R>>((part) => part),
        ),
      );
}

extension EitherObminOpticIsoExtension<Whole, L, R> on Iso<Whole, Either<L, R>> {
  Prism<Whole, Left<L, R>> get left => composeWithPrism(
        Prism<Either<L, R>, Left<L, R>>(
          Preview<Either<L, R>, Left<L, R>>((whole) => whole.leftOrNone.map(Left.new)),
          Getter<Left<L, R>, Either<L, R>>((part) => part),
        ),
      );

  Prism<Whole, Right<L, R>> get right => composeWithPrism(
        Prism<Either<L, R>, Right<L, R>>(
          Preview<Either<L, R>, Right<L, R>>((whole) => whole.rightOrNone.map(Right.new)),
          Getter<Right<L, R>, Either<L, R>>((part) => part),
        ),
      );
}

extension EitherObminOpticPrismExtension<Whole, L, R> on Prism<Whole, Either<L, R>> {
  Prism<Whole, Left<L, R>> get left => compose(
        Prism<Either<L, R>, Left<L, R>>(
          Preview<Either<L, R>, Left<L, R>>((whole) => whole.leftOrNone.map(Left.new)),
          Getter<Left<L, R>, Either<L, R>>((part) => part),
        ),
      );

  Prism<Whole, Right<L, R>> get right => compose(
        Prism<Either<L, R>, Right<L, R>>(
          Preview<Either<L, R>, Right<L, R>>((whole) => whole.rightOrNone.map(Right.new)),
          Getter<Right<L, R>, Either<L, R>>((part) => part),
        ),
      );
}

extension EitherObminOpticReflectorExtension<Whole, L, R> on Reflector<Whole, Either<L, R>> {
  BiPreview<Whole, Left<L, R>> get left => composeWithPrism(
        Prism<Either<L, R>, Left<L, R>>(
          Preview<Either<L, R>, Left<L, R>>((whole) => whole.leftOrNone.map(Left.new)),
          Getter<Left<L, R>, Either<L, R>>((part) => part),
        ),
      );

  BiPreview<Whole, Right<L, R>> get right => composeWithPrism(
        Prism<Either<L, R>, Right<L, R>>(
          Preview<Either<L, R>, Right<L, R>>((whole) => whole.rightOrNone.map(Right.new)),
          Getter<Right<L, R>, Either<L, R>>((part) => part),
        ),
      );
}

extension EitherObminOpticBiPreviewExtension<Whole, L, R> on BiPreview<Whole, Either<L, R>> {
  BiPreview<Whole, Left<L, R>> get left => composeWithPrism(
        Prism<Either<L, R>, Left<L, R>>(
          Preview<Either<L, R>, Left<L, R>>((whole) => whole.leftOrNone.map(Left.new)),
          Getter<Left<L, R>, Either<L, R>>((part) => part),
        ),
      );

  BiPreview<Whole, Right<L, R>> get right => composeWithPrism(
        Prism<Either<L, R>, Right<L, R>>(
          Preview<Either<L, R>, Right<L, R>>((whole) => whole.rightOrNone.map(Right.new)),
          Getter<Right<L, R>, Either<L, R>>((part) => part),
        ),
      );
}
