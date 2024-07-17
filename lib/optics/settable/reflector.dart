// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/getter.dart';
import 'package:obmin/optics/preview.dart';
import 'package:obmin/optics/settable/bi_preview.dart';
import 'package:obmin/optics/settable/iso.dart';
import 'package:obmin/optics/settable/prism.dart';

final class Reflector<Whole, Part> {
  final Getter<Whole, Part> getter;
  final Preview<Part, Whole> preview;

  const Reflector(this.getter, this.preview);

  Reflector<Whole, Sub> compose<Sub>(Reflector<Part, Sub> other) {
    return Reflector(
      getter.compose(other.getter),
      other.preview.compose(preview),
    );
  }

  Reflector<Whole, Sub> composeWithIso<Sub>(Iso<Part, Sub> other) {
    return compose(other.asReflector());
  }

  BiPreview<Whole, Sub> composeWithPrism<Sub>(Prism<Part, Sub> other) {
    return asBiPreview().compose(other.asBiPreview());
  }

  BiPreview<Whole, Sub> composeWithBiPreview<Sub>(BiPreview<Part, Sub> other) {
    return asBiPreview().compose(other);
  }

  @override
  String toString() {
    return "Reflector<$Whole, $Part>";
  }

  BiPreview<Whole, Part> asBiPreview() {
    return BiPreview(
      getter.asPreview(),
      preview,
    );
  }

  Prism<Part, Whole> flipped() {
    return Prism(
      preview,
      getter,
    );
  }
}
