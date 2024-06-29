// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/iso.dart';
import 'package:obmin/a_foundation/types/lens.dart';
import 'package:obmin/a_foundation/types/optics_factory.dart';
import 'package:obmin/a_foundation/types/pair.dart';

extension EitherToLeftPrism on OpticsFactory {
  Lens<Pair<T1, T2>, T1> pairToV1Lens<T1, T2>() {
    return Lens(
      get: (whole) {
        return whole.v1;
      },
      put: (whole, part) {
        return Pair(part, whole.v2);
      },
    );
  }

  Lens<Pair<T1, T2>, T2> pairToV2Lens<T1, T2>() {
    return Lens(
      get: (whole) {
        return whole.v2;
      },
      put: (whole, part) {
        return Pair(whole.v1, part);
      },
    );
  }

  Iso<Pair<T1, T2>, Pair<T2, T1>> pairSwapIso<T1, T2>() {
    return Iso(
      to: (t1) {
        return t1.swapped();
      },
      from: (t2) {
        return t2.swapped();
      },
    );
  }
}
