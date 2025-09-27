// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/flist.dart';

extension FListOpticExtension<S, A> on Optic<S, FList<A>> {
  Optic<S, A> each() {
    return then(Optic.flist<A, A>());
  }
}
