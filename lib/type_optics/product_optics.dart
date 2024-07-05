// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/iso.dart';
import 'package:obmin/optics/lens.dart';
import 'package:obmin/optics/optics_factory.dart';
import 'package:obmin/types/product.dart';

extension ProductOptics on OpticsFactory {
  Lens<Product<T1, T2>, T1> pairToV1Lens<T1, T2>() {
    return Lens(
      get: (whole) {
        return whole.value1;
      },
      put: (whole, part) {
        return Product(part, whole.value2);
      },
    );
  }

  Lens<Product<T1, T2>, T2> pairToV2Lens<T1, T2>() {
    return Lens(
      get: (whole) {
        return whole.value2;
      },
      put: (whole, part) {
        return Product(whole.value1, part);
      },
    );
  }

  Iso<Product<T1, T2>, Product<T2, T1>> pairSwapIso<T1, T2>() {
    return Iso(
      to: (t1) {
        return t1.swapped();
      },
      from: (t2) {
        return t2.swapped();
      },
    );
  }

  Iso<Product<T1, T2>, Product<R, T2>> pairMapV1Iso<T1, T2, R>({
    required R Function(T1 value) to,
    required T1 Function(R value) from,
  }) {
    return Iso(
      to: (whole) {
        return whole.mapV1(to);
      },
      from: (part) {
        return part.mapV1(from);
      },
    );
  }

  Iso<Product<T1, T2>, Product<T1, R>> pairMapV2Iso<T1, T2, R>({
    required R Function(T2 value) to,
    required T2 Function(R value) from,
  }) {
    return Iso(
      to: (whole) {
        return whole.mapV2(to);
      },
      from: (part) {
        return part.mapV2(from);
      },
    );
  }
}
