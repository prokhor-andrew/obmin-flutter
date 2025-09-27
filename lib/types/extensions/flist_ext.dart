// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/flist.dart';

extension FListOpticExtension<S, A> on Optic<S, FList<A>> {
  Optic<S, A> each() {
    return then(Optic.flist<A, A>());
  }

  Optic<S, A> head() {
    return then(Optic.fromRun((update) {
      return (whole) {
        return FList(update(whole.head()), whole.tail());
      };
    }));
  }

  Optic<S, IList<A>> tail() {
    return then(Optic.fromRun((update) {
      return (whole) {
        return FList(whole.head(), update(whole.tail()));
      };
    }));
  }
}
