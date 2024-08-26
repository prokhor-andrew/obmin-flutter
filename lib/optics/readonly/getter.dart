// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/types/optional.dart';

final class Getter<Whole, Part> {
  final Part Function(Whole whole) get;

  const Getter(this.get);

  Getter<Whole, Sub> compose<Sub>(Getter<Part, Sub> other) {
    return Getter((whole) {
      return other.get(get(whole));
    });
  }

  Getter<Whole, Part> composeWithEqv(Eqv<Part> other) {
    return compose(other.asGetter());
  }

  Preview<Whole, Sub> composeWithPreview<Sub>(Preview<Part, Sub> other) {
    return asPreview().compose(other);
  }

  Fold<Whole, Sub> composeWithFold<Sub>(Fold<Part, Sub> other) {
    return asFold().compose(other);
  }

  @override
  String toString() {
    return "Getter<$Whole, $Part>";
  }

  Preview<Whole, Part> asPreview() {
    return Preview((whole) {
      return Optional<Part>.some(get(whole));
    });
  }

  Fold<Whole, Part> asFold() {
    return asPreview().asFold();
  }
}
