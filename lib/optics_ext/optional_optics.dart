// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/optics_factory.dart';
import 'package:obmin/optics/prism.dart';
import 'package:obmin/types/optional.dart';

extension OptionalOptics on OpticsFactory {
  Prism<Optional<T>, T> optionalToValuePrism<T>() {
    return Prism(
      get: (whole) {
        return whole;
      },
      set: Some.new,
    );
  }
}
