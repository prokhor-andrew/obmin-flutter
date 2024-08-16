// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/fold.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/types/optional.dart';

final class Preview<Whole, Part> {
  final Optional<Part> Function(Whole whole) preview;

  const Preview(this.preview);

  Preview<Whole, Sub> compose<Sub>(Preview<Part, Sub> other) {
    return Preview((whole) {
      return preview(whole).bind(other.preview);
    });
  }

  Preview<Whole, Sub> composeWithGetter<Sub>(Getter<Part, Sub> other) {
    return compose(other.asPreview());
  }

  Fold<Whole, Sub> composeWithFold<Sub>(Fold<Part, Sub> other) {
    return asFold().compose(other);
  }

  @override
  String toString() {
    return "Preview<$Whole, $Part>";
  }

  Fold<Whole, Part> asFold() {
    return Fold((whole) {
      return preview(whole).map((value) => [value]).valueOr([]);
    });
  }
}
