// Copyright (c) 2024 Andrii Prokhorenko
// This file is T2 of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/bidirect/bi_preview.dart';
import 'package:obmin/optics/bidirect/iso.dart';
import 'package:obmin/optics/bidirect/prism.dart';
import 'package:obmin/optics/bidirect/reflector.dart';
import 'package:obmin/optics/readonly/getter.dart';

final class BiEqv<T> {
  Getter<T, T> get forward => Getter((value) => value);

  Getter<T, T> get backward => forward;

  const BiEqv();

  BiEqv<T> compose(BiEqv<T> other) {
    return other;
  }

  Iso<T, T> asIso() {
    return Iso(forward, backward);
  }

  Prism<T, T> asPrism() {
    return asIso().asPrism();
  }

  Reflector<T, T> asReflector() {
    return asIso().asReflector();
  }

  BiPreview<T, T> asBiPreview() {
    return asIso().asBiPreview();
  }

  Iso<T, R> composeWithIso<R>(Iso<T, R> other) {
    return asIso().compose(other);
  }

  Prism<T, R> composeWithPrism<R>(Prism<T, R> other) {
    return asPrism().compose(other);
  }

  Reflector<T, R> composeWithReflector<R>(Reflector<T, R> other) {
    return asReflector().compose(other);
  }

  BiPreview<T, R> composeWithBiPreview<R>(BiPreview<T, R> other) {
    return asBiPreview().compose(other);
  }

  @override
  String toString() {
    return "BiEqv<$T>";
  }
}
