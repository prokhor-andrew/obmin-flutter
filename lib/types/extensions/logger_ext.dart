// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/logger.dart';

extension LoggerOpticExtension<S, A> on Optic<S, Logger<A>> {
  Optic<S, A> value() {
    return then(Optic.logger<A>());
  }
}

extension LoggerPathArrowExtension<State, Whole, A> on PathArrow<State, Whole, Logger<A>> {
  PathArrow<State, Whole, A> value() {
    return then(PathArrow.logger<State, A>());
  }
}
