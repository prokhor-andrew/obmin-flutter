// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/a_foundation/types/prism.dart';

final class Lens<Whole, Part> {
  final Part Function(Whole whole) get;
  final Whole Function(Whole whole, Part part) put;

  Lens({
    required this.get,
    required this.put,
  });

  @override
  String toString() {
    return "$Lens<$Whole, $Part>";
  }

  static Lens<T, T> identity<T>() {
    return Lens(
      get: (whole) {
        return whole;
      },
      put: (whole, part) {
        return part;
      },
    );
  }
}

extension LensCompose<Whole, Part> on Lens<Whole, Part> {
  Lens<Whole, SubPart> composeWithLens<SubPart>(Lens<Part, SubPart> lens) {
    SubPart resultGet(Whole whole) {
      return lens.get(get(whole));
    }

    Whole resultPut(Whole whole, SubPart subPart) {
      return put(whole, lens.put(get(whole), subPart));
    }

    return Lens(get: resultGet, put: resultPut);
  }

  Prism<Whole, SubPart> composeWithPrism<SubPart>(Prism<Part, SubPart> prism) {
    Optional<SubPart> resultGet(Whole whole) {
      return prism.get(get(whole));
    }

    Whole resultPut(Whole whole, SubPart subPart) {
      return put(whole, prism.put(get(whole), subPart));
    }

    return Prism(get: resultGet, put: resultPut);
  }
}
