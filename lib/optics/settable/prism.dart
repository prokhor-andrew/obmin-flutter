// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/getter.dart';
import 'package:obmin/optics/preview.dart';
import 'package:obmin/optics/settable/bi_preview.dart';
import 'package:obmin/optics/settable/iso.dart';
import 'package:obmin/optics/settable/reflector.dart';

final class Prism<Whole, Part> {
  final Preview<Whole, Part> tryGet;
  final Getter<Part, Whole> inject;

  const Prism(this.tryGet, this.inject);

  Prism<Whole, Sub> compose<Sub>(Prism<Part, Sub> other) {
    return Prism(
      tryGet.compose(other.tryGet),
      other.inject.compose(inject),
    );
  }

  Prism<Whole, Sub> composeWithIso<Sub>(Iso<Part, Sub> other) {
    return compose(other.asPrism());
  }

  BiPreview<Whole, Sub> composeWithReflector<Sub>(Reflector<Part, Sub> other) {
    return asBiPreview().compose(other.asBiPreview());
  }

  BiPreview<Whole, Sub> composeWithBiPreview<Sub>(BiPreview<Part, Sub> other) {
    return asBiPreview().compose(other);
  }

  @override
  String toString() {
    return "Prism<$Whole, $Part>";
  }

  BiPreview<Whole, Part> asBiPreview() {
    return BiPreview(
      tryGet,
      inject.asPreview(),
    );
  }

  Reflector<Part, Whole> flipped() {
    return Reflector(
      inject,
      tryGet,
    );
  }
}
