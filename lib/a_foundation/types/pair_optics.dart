// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/lens.dart';
import 'package:obmin/a_foundation/types/pair.dart';
import 'package:obmin/a_foundation/types/prism.dart';

Lens<Pair<T1, T2>, T1> PairToV1Lens<T1, T2>() {
  return Lens(
    get: (whole) {
      return whole.v1;
    },
    put: (whole, part) {
      return Pair(part, whole.v2);
    },
  );
}

Lens<Pair<T1, T2>, T2> PairToV2Lens<T1, T2>() {
  return Lens(
    get: (whole) {
      return whole.v2;
    },
    put: (whole, part) {
      return Pair(whole.v1, part);
    },
  );
}

extension PairToV1LensExtension<Whole, T1, T2> on Lens<Whole, Pair<T1, T2>> {
  Lens<Whole, T1> zoomIntoV1() {
    return composeWithLens(PairToV1Lens<T1, T2>());
  }

  Lens<Whole, T2> zoomIntoV2() {
    return composeWithLens(PairToV2Lens<T1, T2>());
  }
}

extension PairToV1PrismExtension<Whole, T1, T2> on Prism<Whole, Pair<T1, T2>> {
  Prism<Whole, T1> zoomIntoV1() {
    return composeWithLens(PairToV1Lens<T1, T2>());
  }

  Prism<Whole, T2> zoomIntoV2() {
    return composeWithLens(PairToV2Lens<T1, T2>());
  }
}
