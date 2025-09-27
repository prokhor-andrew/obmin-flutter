// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/writer.dart';

extension WriterOpticExtension<S, A, B> on Optic<S, Writer<A, B>> {
  Optic<S, IList<A>> list() {
    return then(Optic.writerList<B, A>());
  }

  Optic<S, B> value() {
    return then(Optic.writerValue<A, B>());
  }
}

extension WriterPathArrowExtension<State, Whole, A, B> on PathArrow<State, Whole, Writer<A, B>> {
  PathArrow<State, Whole, IList<A>> list() {
    return then(PathArrow.writerList<State, B, A>());
  }

  PathArrow<State, Whole, B> value() {
    return then(PathArrow.writerValue<State, A, B>());
  }
}
