// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/iso.dart';
import 'package:obmin/a_foundation/types/lens.dart';
import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/a_foundation/types/prism.dart';

final class Affine<Whole, Part> {
  final Optional<Part> Function(Whole) get;
  final Optional<Whole> Function(Whole whole, Part part) put;

  Affine({
    required this.get,
    required this.put,
  });

  @override
  String toString() {
    return "$Affine<$Whole, $Part>";
  }

  Affine<Whole, SubPart> then<SubPart>(Affine<Part, SubPart> affine) {
    return Affine(
      get: (whole) {
        return get(whole).bind(affine.get);
      },
      put: (whole, subPart) {
        return get(whole).bind((part) {
          return affine.put(part, subPart);
        }).bind((newPart) {
          return put(whole, newPart);
        });
      },
    );
  }
}

extension IsoToAffine<T1, T2> on Iso<T1, T2> {
  Affine<T1, T2> toAffine() {
    return Affine(
      get: (whole) {
        return Some(to(whole));
      },
      put: (whole, part) {
        return Some(from(part));
      },
    );
  }
}

extension LensToAffine<Whole, Part> on Lens<Whole, Part> {
  Affine<Whole, Part> toAffine() {
    return Affine(
      get: (whole) {
        return Some(get(whole));
      },
      put: (whole, part) {
        return Some(put(whole, part));
      },
    );
  }
}

extension PrismToAffine<Whole, Part> on Prism<Whole, Part> {
  Affine<Whole, Part> toAffine() {
    return Affine(
      get: (whole) {
        return get(whole);
      },
      put: (whole, part) {
        return Some(set(part));
      },
    );
  }
}
