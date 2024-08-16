// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/fold.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

final class Eqv<T> {
  const Eqv();

  T identity(T value) => value;

  Getter<T, T> asGetter() {
    return Getter(identity);
  }

  Preview<T, T> asPreview() {
    return asGetter().asPreview();
  }

  Fold<T, T> asFold() {
    return asGetter().asFold();
  }

  @override
  String toString() {
    return "Eqv<$T>";
  }
}
