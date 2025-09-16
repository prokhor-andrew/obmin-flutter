// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/func.dart';

extension TupleExtensions<A, B> on (A, B) {
  (A2, B) lmap<A2>(Func<A, A2> f) {
    return (f($1), $2);
  }

  (A, B2) rmap<B2>(Func<B, B2> f) {
    return ($1, f($2));
  }

  (A, B2) map<B2>(Func<B, B2> f) {
    return rmap(f);
  }

  (A2, B2) bimap<A2, B2>(Func<A, A2> lf, Func<B, B2> rf) {
    return lmap(lf).rmap(rf);
  }
}
