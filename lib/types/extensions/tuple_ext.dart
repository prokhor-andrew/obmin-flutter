// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/optic.dart';

extension TupleOpticExtension<S, A, B> on Optic<S, (A, B)> {
  Optic<S, A> left() {
    return then(Optic.tupleLeft<B, A, A>());
  }

  Optic<S, B> right() {
    return then(Optic.tuple<A, B, B>());
  }
}
