// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/either.dart';

extension EitherOpticExtension<S, A, B> on Optic<S, Either<A, B>> {
  Optic<S, A> left() {
    return then(Optic.eitherLeft<B, A>());
  }

  Optic<S, B> right() {
    return then(Optic.either<A, B>());
  }
}

extension EitherPathArrowExtension<State, Whole, A, B> on PathArrow<State, Whole, Either<A, B>> {
  PathArrow<State, Whole, A> left() {
    return then(PathArrow.eitherLeft<State, B, A>());
  }

  PathArrow<State, Whole, B> right() {
    return then(PathArrow.either<State, A, B>());
  }
}
