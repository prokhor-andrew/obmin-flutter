// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/optional.dart';

final class Prism<Whole, Part> {
  final Optional<Part> Function(Whole whole) get;
  final Whole Function(Part part) set;

  Prism({
    required this.get,
    required this.set,
  });

  @override
  String toString() {
    return "$Prism<$Whole, $Part>";
  }

  Prism<Whole, SubPart> then<SubPart>(Prism<Part, SubPart> prism) {
    return Prism(
      get: (whole) {
        return get(whole).bind((value) {
          return prism.get(value);
        });
      },
      set: (subPart) {
        return set(prism.set(subPart));
      },
    );
  }
}
