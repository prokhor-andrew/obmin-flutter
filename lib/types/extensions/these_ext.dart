// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/these.dart';

extension TheseOpticExtension<S, A, B> on Optic<S, These<A, B>> {
  Optic<S, B> right() {
    return then(Optic.theseRight<A, B>());
  }

  Optic<S, A> left() {
    return then(Optic.theseLeft<B, A>());
  }
}

extension ThesePathArrowExtension<State, Whole, A, B> on PathArrow<State, Whole, These<A, B>> {
  PathArrow<State, Whole, A> left() {
    return then(PathArrow.theseLeft<State, B, A>());
  }

  PathArrow<State, Whole, B> right() {
    return then(PathArrow.theseRight<State, A, B>());
  }
}
