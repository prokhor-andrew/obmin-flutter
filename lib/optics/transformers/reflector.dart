// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/optics/transformers/bi_preview.dart';
import 'package:obmin/optics/transformers/iso.dart';
import 'package:obmin/optics/transformers/prism.dart';

final class Reflector<Whole, Part> {
  final Getter<Whole, Part> forward;
  final Preview<Part, Whole> backward;

  const Reflector(this.forward, this.backward);

  Reflector<Whole, Sub> compose<Sub>(Reflector<Part, Sub> other) {
    return Reflector(
      forward.compose(other.forward),
      other.backward.compose(backward),
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
      forward.asPreview(),
      backward,
    );
  }

  Prism<Part, Whole> flipped() {
    return Prism(
      backward,
      forward,
    );
  }
}
