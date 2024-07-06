// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/affine.dart';
import 'package:obmin/optics/iso.dart';
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

  Iso<Optional<T>, Optional<R>> optionalMapIso<T, R>({
    required R Function(T value) to,
    required T Function(R value) from,
  }) {
    return Iso(
      to: (whole) {
        return whole.map(to);
      },
      from: (part) {
        return part.map(from);
      },
    );
  }
}

extension OptionalZoom<Whole, T> on Affine<Whole, Optional<T>> {
  Affine<Whole, T> zoomIntoValue() {
    return then(OpticsFactory.shared.optionalToValuePrism<T>().asAffine());
  }

  Affine<Whole, Optional<R>> zoomIntoMap<R>({
    required R Function(T value) to,
    required T Function(R value) from,
  }) {
    return then(OpticsFactory.shared.optionalMapIso(to: to, from: from).asAffine());
  }
}
