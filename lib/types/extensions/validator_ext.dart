// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/validator.dart';

extension ValidatorOpticExtension<S, A, B> on Optic<S, Validator<A, B>> {
  Optic<S, B> value() {
    return then(Optic.validatorValue<A, B>());
  }

  Optic<S, IList<A>> errors() {
    return then(Optic.validatorErrors<B, A>());
  }
}

extension WriterPathArrowExtension<State, Whole, A, B> on PathArrow<State, Whole, Validator<A, B>> {
  PathArrow<State, Whole, IList<A>> errors() {
    return then(PathArrow.validatorErrors<State, B, A>());
  }

  PathArrow<State, Whole, B> value() {
    return then(PathArrow.validatorValue<State, A, B>());
  }
}
