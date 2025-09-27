// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/optics/optic.dart';

extension TupleOpticExtension<S, A, B> on Optic<S, (A, B)> {
  Optic<S, A> left() {
    return then(Optic.tupleLeft<B, A, A>());
  }

  Optic<S, B> right() {
    return then(Optic.tuple<A, B, B>());
  }
}

extension TuplePathArrowExtension<State, Whole, A, B> on PathArrow<State, Whole, (A, B)> {
  PathArrow<State, Whole, A> left() {
    return then(PathArrow.tupleLeft<State, B, A>());
  }

  PathArrow<State, Whole, B> right() {
    return then(PathArrow.tuple<State, A, B>());
  }
}
