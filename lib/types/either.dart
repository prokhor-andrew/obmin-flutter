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
import 'package:obmin/utils/bool_fold.dart';

final class Either<L, R> {
  final bool _isLeft;
  final L? _left;
  final R? _right;

  const Either.left(L left)
      : _left = left,
        _right = null,
        _isLeft = true;

  const Either.right(R right)
      : _right = right,
        _left = null,
        _isLeft = false;

  T fold<T>(
    T Function(L value) ifLeft,
    T Function(R value) ifRight,
  ) {
    return _isLeft.fold<T>(
      () => ifLeft(_left!),
      () => ifRight(_right!),
    );
  }

  @override
  String toString() {
    return fold<String>(
      (value) => "Either<$L, $R> Left=$value",
      (value) => "Either<$L, $R> Right=$value",
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Either<L, R>) return false;

    if (_isLeft != other._isLeft) {
      return false;
    }
    if (_isLeft) {
      return _left == other._left;
    } else {
      return _right == other._right;
    }
  }

  @override
  int get hashCode => _isLeft ? _left.hashCode : _right.hashCode;

  Either<R, L> swapped() {
    return fold<Either<R, L>>(
      Either<R, L>.right,
      Either<R, L>.left,
    );
  }

  Either<T, R> bindLeft<T>(Either<T, R> Function(L value) function) {
    return fold<Either<T, R>>(
      function,
      Either<T, R>.right,
    );
  }

  Either<T, R> mapLeft<T>(T Function(L value) function) {
    return bindLeft<T>((value) => Either<T, R>.left(function(value)));
  }

  Either<T, R> mapLeftTo<T>(T value) {
    return mapLeft<T>((_) => value);
  }

  Either<L, T> bindRight<T>(Either<L, T> Function(R value) function) {
    return fold<Either<L, T>>(
      Either<L, T>.left,
      function,
    );
  }

  Either<L, T> mapRight<T>(T Function(R value) function) {
    return swapped().mapLeft<T>(function).swapped();
  }

  Either<L, T> mapRightTo<T>(T value) {
    return mapRight<T>((_) => value);
  }

  Optional<L> get leftOrNone => fold<Optional<L>>(
        (left) => Optional<L>.some(left),
        (right) => Optional<L>.none(),
      );

  Optional<R> get rightOrNone => swapped().leftOrNone;

  bool get isLeft => leftOrNone.mapTo(true).valueOr(false);

  bool get isRight => !isLeft;

  void executeIfLeft(void Function(L value) function) {
    fold<void Function()>(
      (value) => () => function(value),
      (_) => () {},
    );
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

  static Eqv<Either<L, R>> eqv<L, R>() => Eqv<Either<L, R>>();

  static Mutator<Either<L, R>, Either<L, R>> setter<L, R>() => Mutator.setter<Either<L, R>>();
}

extension EitherValueWhenBothExtension<T> on Either<T, T> {
  T get value => fold<T>(
        (val) => val,
        (val) => val,
      );
}

extension EitherObminOpticEqvExtension<L, R> on Eqv<Either<L, R>> {
  Preview<Either<L, R>, L> get left => Preview<Either<L, R>, L>((whole) => whole.leftOrNone);

  Preview<Either<L, R>, R> get right => Preview<Either<L, R>, R>((whole) => whole.rightOrNone);
}

extension EitherObminOpticGetterExtension<Whole, L, R> on Getter<Whole, Either<L, R>> {
  Preview<Whole, L> get left => composeWithPreview(Preview<Either<L, R>, L>((whole) => whole.leftOrNone));

  Preview<Whole, R> get right => composeWithPreview(Preview<Either<L, R>, R>((whole) => whole.rightOrNone));
}

extension EitherObminOpticPreviewExtension<Whole, L, R> on Preview<Whole, Either<L, R>> {
  Preview<Whole, L> get left => compose(Preview<Either<L, R>, L>((whole) => whole.leftOrNone));

  Preview<Whole, R> get right => compose(Preview<Either<L, R>, R>((whole) => whole.rightOrNone));
}

extension EitherObminOpticFoldExtension<Whole, L, R> on Fold<Whole, Either<L, R>> {
  Fold<Whole, L> get left => composeWithPreview(Preview<Either<L, R>, L>((whole) => whole.leftOrNone));

  Fold<Whole, R> get right => composeWithPreview(Preview<Either<L, R>, R>((whole) => whole.rightOrNone));
}

extension EitherObminOpticMutatorExtension<Whole, L, R> on Mutator<Whole, Either<L, R>> {
  Mutator<Whole, L> get left => composeWithPrism(
        Prism<Either<L, R>, L>(
          Preview<Either<L, R>, L>((whole) => whole.leftOrNone),
          Getter<L, Either<L, R>>(Either<L, R>.left),
        ),
      );

  Mutator<Whole, R> get right => composeWithPrism(
        Prism<Either<L, R>, R>(
          Preview<Either<L, R>, R>((whole) => whole.rightOrNone),
          Getter<R, Either<L, R>>(Either<L, R>.right),
        ),
      );
}

extension EitherObminOpticIsoExtension<Whole, L, R> on Iso<Whole, Either<L, R>> {
  Prism<Whole, L> get left => composeWithPrism(
        Prism<Either<L, R>, L>(
          Preview<Either<L, R>, L>((whole) => whole.leftOrNone),
          Getter<L, Either<L, R>>(Either<L, R>.left),
        ),
      );

  Prism<Whole, R> get right => composeWithPrism(
        Prism<Either<L, R>, R>(
          Preview<Either<L, R>, R>((whole) => whole.rightOrNone),
          Getter<R, Either<L, R>>(Either<L, R>.right),
        ),
      );
}

extension EitherObminOpticPrismExtension<Whole, L, R> on Prism<Whole, Either<L, R>> {
  Prism<Whole, L> get left => compose(
        Prism<Either<L, R>, L>(
          Preview<Either<L, R>, L>((whole) => whole.leftOrNone),
          Getter<L, Either<L, R>>(Either<L, R>.left),
        ),
      );

  Prism<Whole, R> get right => compose(
        Prism<Either<L, R>, R>(
          Preview<Either<L, R>, R>((whole) => whole.rightOrNone),
          Getter<R, Either<L, R>>(Either<L, R>.right),
        ),
      );
}

extension EitherObminOpticReflectorExtension<Whole, L, R> on Reflector<Whole, Either<L, R>> {
  BiPreview<Whole, L> get left => composeWithPrism(
        Prism<Either<L, R>, L>(
          Preview<Either<L, R>, L>((whole) => whole.leftOrNone),
          Getter<L, Either<L, R>>(Either<L, R>.left),
        ),
      );

  BiPreview<Whole, R> get right => composeWithPrism(
        Prism<Either<L, R>, R>(
          Preview<Either<L, R>, R>((whole) => whole.rightOrNone),
          Getter<R, Either<L, R>>(Either<L, R>.right),
        ),
      );
}

extension EitherObminOpticBiPreviewExtension<Whole, L, R> on BiPreview<Whole, Either<L, R>> {
  BiPreview<Whole, L> get left => composeWithPrism(
        Prism<Either<L, R>, L>(
          Preview<Either<L, R>, L>((whole) => whole.leftOrNone),
          Getter<L, Either<L, R>>(Either<L, R>.left),
        ),
      );

  BiPreview<Whole, R> get right => composeWithPrism(
        Prism<Either<L, R>, R>(
          Preview<Either<L, R>, R>((whole) => whole.rightOrNone),
          Getter<R, Either<L, R>>(Either<L, R>.right),
        ),
      );
}
