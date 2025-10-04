// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/arrows/option_arrow.dart';
import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/option.dart';

extension OptionOpticExtension<S, A> on Optic<S, Option<A>> {
  Optic<S, A> some() {
    return then<A>(Optic.option<A>());
  }
}

extension OptionPathArrowExtension<Whole, A> on PathArrow<Whole, Option<A>> {
  PathArrow<Whole, A> some() {
    return then<A>(PathArrow.option<A>());
  }
}

extension OptionOptionArrowExtension<Whole, A> on OptionArrow<Whole, Option<A>> {
  OptionArrow<Whole, A> some() {
    return then<A>(OptionArrow.option<A>());
  }
}
