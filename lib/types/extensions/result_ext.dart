// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/result.dart';

extension ResultOpticExtension<S, A, B> on Optic<S, Result<A, B>> {
  Optic<S, A> failure() {
    return then(Optic.resultFailure<B, A, A>());
  }

  Optic<S, B> success() {
    return then(Optic.resultSuccess<A, B, B>());
  }
}
