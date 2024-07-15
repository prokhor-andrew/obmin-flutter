// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/getter.dart';
import 'package:obmin/optics/preview.dart';

final class Fold<Whole, Part> {
  final Iterable<Part> Function(Whole whole) fold;

  const Fold(this.fold);

  Fold<Whole, Sub> compose<Sub>(Fold<Part, Sub> other) {
    return Fold((whole) {
      return fold(whole).expand(other.fold);
    });
  }

  Fold<Whole, Sub> composeWithGetter<Sub>(Getter<Part, Sub> other) {
    return compose(other.asFold());
  }

  Fold<Whole, Sub> composeWithPreview<Sub>(Preview<Part, Sub> other) {
    return compose(other.asFold());
  }

  @override
  String toString() {
    return "Fold<$Whole, $Part>";
  }
}
