// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/optional.dart';

Set<Element> uniteSetOptionals<Element>(Set<Optional<Element>> optionals) {
  final Set<Element> result = {};

  for (final element in optionals) {
    switch (element) {
      case None<Element>():
        break;
      case Some<Element>(value: final value):
        result.add(value);
    }
  }

  return result;
}
