// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/result.dart';

extension ResultOpticExtension<S, A, B> on Optic<S, Result<A, B>> {
  Optic<S, A> failure() {
    return then(Optic.resultFailure<B, A>());
  }

  Optic<S, B> success() {
    return then(Optic.resultSuccess<A, B>());
  }
}

extension ResultPathArrowExtension<State, Whole, A, B> on PathArrow<State, Whole, Result<A, B>> {
  PathArrow<State, Whole, A> failure() {
    return then(PathArrow.resultFailure<State, B, A>());
  }

  PathArrow<State, Whole, B> success() {
    return then(PathArrow.resultSuccess<State, A, B>());
  }
}
