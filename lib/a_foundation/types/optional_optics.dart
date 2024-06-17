// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/a_foundation/types/prism.dart';

Prism<Optional<T>, T> OptionalToValuePrism<T>() {
  return Prism(
    get: (whole) {
      return whole;
    },
    put: (whole, part) {
      return Some(part);
    },
  );
}

extension OptionalPrismExtension<Whole, T> on Prism<Whole, Optional<T>> {
  Prism<Whole, T> zoomIntoValue() {
    return composeWithPrism(OptionalToValuePrism<T>());
  }
}
