// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/call.dart';

extension CallOpticExtension<S, A, B> on Optic<S, Call<A, B>> {
  Optic<S, A> launched() {
    return then(Optic.callLaunched<B, A, A>());
  }

  Optic<S, B> returned() {
    return then(Optic.callReturned<A, B, B>());
  }
}
