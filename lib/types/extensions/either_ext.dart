// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/either.dart';

extension EitherOpticExtension<S, A, B> on Optic<S, Either<A, B>> {
  Optic<S, A> left() {
    return then(Optic.eitherLeft<B, A, A>());
  }

  Optic<S, B> right() {
    return then(Optic.either<A, B, B>());
  }
  Optic<S, A> launched() {
    return then(Optic.eitherLeft<B, A, A>());
  }

  Optic<S, B> returned() {
    return then(Optic.either<A, B, B>());
  }

  Optic<S, A> failure() {
    return then(Optic.eitherLeft<B, A, A>());
  }

  Optic<S, B> success() {
    return then(Optic.either<A, B, B>());
  }
}
