// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/optional.dart';

final class Prism<Whole, Part> {
  final Optional<Part> Function(Whole whole) get;
  final Whole Function(Whole whole, Part part) put;

  Prism({
    required this.get,
    required this.put,
  });

  @override
  String toString() {
    return "$Prism<$Whole, $Part>";
  }
}

extension PrismCompose<Whole, Part> on Prism<Whole, Part> {
  Prism<Whole, SubPart> compose<SubPart>(Prism<Part, SubPart> prism) {
    Optional<SubPart> resultGet(Whole whole) {
      return get(whole).bind((value) {
        return prism.get(value);
      });
    }

    Whole resultPut(Whole whole, SubPart subPart) {
      return get(whole).map((part) {
        return prism.put(part, subPart);
      }).map((part) {
        return put(whole, part);
      }).valueOr(whole);
    }

    return Prism(get: resultGet, put: resultPut);
  }
}
