// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/optics/bidirect/bi_preview.dart';
import 'package:obmin/optics/bidirect/iso.dart';
import 'package:obmin/optics/bidirect/reflector.dart';

final class Prism<Whole, Part> {
  final Preview<Whole, Part> forward;
  final Getter<Part, Whole> backward;

  const Prism(this.forward, this.backward);

  Prism<Whole, Sub> compose<Sub>(Prism<Part, Sub> other) {
    return Prism(
      forward.compose(other.forward),
      other.backward.compose(backward),
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
      forward,
      backward.asPreview(),
    );
  }

  Reflector<Part, Whole> flipped() {
    return Reflector(
      backward,
      forward,
    );
  }
}
