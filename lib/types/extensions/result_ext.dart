// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/arrows/option_arrow.dart';
import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/result.dart';

extension ResultOpticExtension<S, A, B> on Optic<S, Result<A, B>> {
  Optic<S, A> failure() {
    return then<A>(Optic.resultFailure<B, A>());
  }

  Optic<S, B> success() {
    return then<B>(Optic.resultSuccess<A, B>());
  }
}

extension ResultPathArrowExtension<Whole, A, B> on PathArrow<String, Whole, Result<A, B>> {
  PathArrow<String, Whole, A> failure() {
    return then<A>(PathArrow.resultFailure<B, A>());
  }

  PathArrow<String, Whole, B> success() {
    return then<B>(PathArrow.resultSuccess<A, B>());
  }
}

extension ResultOptionArrowExtension<Whole, A, B> on OptionArrow<Whole, Result<A, B>> {
  OptionArrow<Whole, A> failure() {
    return then<A>(OptionArrow.resultFailure<B, A>());
  }

  OptionArrow<Whole, B> success() {
    return then<B>(OptionArrow.resultSuccess<A, B>());
  }
}
