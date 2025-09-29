// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/these.dart';

extension TheseOpticExtension<S, A, B> on Optic<S, These<A, B>> {
  Optic<S, B> right() {
    return then<B>(Optic.theseRight<A, B>());
  }

  Optic<S, A> left() {
    return then<A>(Optic.theseLeft<B, A>());
  }
}

extension ThesePathArrowExtension<Whole, A, B> on PathArrow<Whole, These<A, B>> {
  PathArrow<Whole, A> left() {
    return then<A>(PathArrow.theseLeft<B, A>());
  }

  PathArrow<Whole, B> right() {
    return then<B>(PathArrow.theseRight<A, B>());
  }
}
