// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/bidirect/bi_preview.dart';
import 'package:obmin/optics/bidirect/prism.dart';
import 'package:obmin/optics/bidirect/reflector.dart';

final class Iso<T1, T2> {
  final Getter<T1, T2> forward;
  final Getter<T2, T1> backward;

  const Iso(this.forward, this.backward);

  Iso<T1, T3> compose<T3>(Iso<T2, T3> other) {
    return Iso(
      forward.compose(other.forward),
      other.backward.compose(backward),
    );
  }

  Prism<T1, T3> composeWithPrism<T3>(Prism<T2, T3> other) {
    return asPrism().compose(other);
  }

  Reflector<T1, T3> composeWithReflector<T3>(Reflector<T2, T3> other) {
    return asReflector().compose(other);
  }

  BiPreview<T1, T3> composeWithBiPreview<T3>(BiPreview<T2, T3> other) {
    return asBiPreview().compose(other);
  }

  @override
  String toString() {
    return "Iso<$T1, $T2>";
  }

  Prism<T1, T2> asPrism() {
    return Prism(
      forward.asPreview(),
      backward,
    );
  }

  Reflector<T1, T2> asReflector() {
    return Reflector(
      forward,
      backward.asPreview(),
    );
  }

  BiPreview<T1, T2> asBiPreview() {
    return BiPreview(
      forward.asPreview(),
      backward.asPreview(),
    );
  }

  Iso<T2, T1> flipped() {
    return Iso(
      backward,
      forward,
    );
  }
}
