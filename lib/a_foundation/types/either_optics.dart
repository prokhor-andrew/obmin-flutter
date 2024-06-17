// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/either.dart';
import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/a_foundation/types/prism.dart';

Prism<Either<L, R>, L> EitherToLeftPrism<L, R>() {
  return Prism(
    get: (whole) {
      switch (whole) {
        case Left<L, R>(value: final value):
          return Some(value);
        case Right<L, R>():
          return None();
      }
    },
    put: (whole, part) {
      return Left(part);
    },
  );
}

Prism<Either<L, R>, R> EitherToRightPrism<L, R>() {
  return Prism(
    get: (whole) {
      switch (whole) {
        case Left<L, R>():
          return None();
        case Right<L, R>(value: final value):
          return Some(value);
      }
    },
    put: (whole, part) {
      return Right(part);
    },
  );
}

extension EitherPrismExtension<Whole, Left, Right> on Prism<Whole, Either<Left, Right>> {
  Prism<Whole, Left> zoomIntoLeft() {
    return composeWithPrism(EitherToLeftPrism<Left, Right>());
  }

  Prism<Whole, Right> zoomIntoRight() {
    return composeWithPrism(EitherToRightPrism<Left, Right>());
  }
}

