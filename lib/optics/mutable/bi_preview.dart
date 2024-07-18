// Copyright (c) 2024 Andrii Prokhorenko
// This file is T2 of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/preview.dart';
import 'package:obmin/optics/mutable/iso.dart';
import 'package:obmin/optics/mutable/prism.dart';
import 'package:obmin/optics/mutable/reflector.dart';

final class BiPreview<T1, T2> {
  final Preview<T1, T2> forward;
  final Preview<T2, T1> backward;

  const BiPreview(this.forward, this.backward);

  BiPreview<T1, T3> compose<T3>(BiPreview<T2, T3> other) {
    return BiPreview(
      forward.compose(other.forward),
      other.backward.compose(backward),
    );
  }

  BiPreview<T1, T3> composeWithIso<T3>(Iso<T2, T3> other) {
    return compose(other.asBiPreview());
  }

  BiPreview<T1, T3> composeWithReflector<T3>(Reflector<T2, T3> other) {
    return compose(other.asBiPreview());
  }

  BiPreview<T1, T3> composeWithPrism<T3>(Prism<T2, T3> other) {
    return compose(other.asBiPreview());
  }

  @override
  String toString() {
    return "BiPreview<$T1, $T2>";
  }

  BiPreview<T2, T1> flipped() {
    return BiPreview(
      backward,
      forward,
    );
  }
}
