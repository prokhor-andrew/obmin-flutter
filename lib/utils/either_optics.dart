// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/fp/either.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

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

extension EitherObminOpticFoldSetExtension<Whole, L, R> on FoldSet<Whole, Either<L, R>> {
  FoldSet<Whole, L> get left => composeWithPreview(Preview<Either<L, R>, L>((whole) => whole.leftOrNone));

  FoldSet<Whole, R> get right => composeWithPreview(Preview<Either<L, R>, R>((whole) => whole.rightOrNone));
}

extension EitherObminOpticMutatorExtension<Whole, L, R> on Mutator<Whole, Either<L, R>> {
  Mutator<Whole, L> get left => compose(
        Mutator.prism<Either<L, R>, L>(
          Preview<Either<L, R>, L>((whole) => whole.leftOrNone),
          Getter<L, Either<L, R>>(Either<L, R>.left),
        ),
      );

  Mutator<Whole, R> get right => compose(
        Mutator.prism<Either<L, R>, R>(
          Preview<Either<L, R>, R>((whole) => whole.rightOrNone),
          Getter<R, Either<L, R>>(Either<L, R>.right),
        ),
      );
}
