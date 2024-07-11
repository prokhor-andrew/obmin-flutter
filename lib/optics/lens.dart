// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/iso.dart';

final class Lens<Whole, Part> {
  final Part Function(Whole whole) get;
  final Whole Function(Whole whole, Part part) put;

  Lens({
    required this.get,
    required this.put,
  });

  @override
  String toString() {
    return "Lens<$Whole, $Part>";
  }

  Lens<Whole, SubPart> then<SubPart>(Lens<Part, SubPart> lens) {
    return Lens(
      get: (whole) {
        return lens.get(get(whole));
      },
      put: (whole, subPart) {
        return put(whole, lens.put(get(whole), subPart));
      },
    );
  }

  Whole modify(Whole whole, Part Function(Part part) transform) {
    return put(whole, transform(get(whole)));
  }
}

extension IsoAsLens<T1, T2> on Iso<T1, T2> {
  Lens<T1, T2> asLens() {
    return Lens(
      get: (whole) {
        return to(whole);
      },
      put: (_, part) {
        return from(part);
      },
    );
  }
}
