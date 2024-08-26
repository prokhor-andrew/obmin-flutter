// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/types/optional.dart';
import 'package:obmin/utils/bool_fold.dart';

final class Fold<Whole, Part> {
  final Iterable<Part> Function(Whole whole) get;

  const Fold(this.get);

  Fold<Whole, Sub> compose<Sub>(Fold<Part, Sub> other) {
    return Fold((whole) {
      return get(whole).expand(other.get);
    });
  }

  Fold<Whole, Part> composeWithEqv(Eqv<Part> other) {
    return compose(other.asFold());
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

  Preview<Whole, Iterable<Part>> asPreview() {
    return Preview((whole) {
      final iterable = get(whole);

      return iterable.isEmpty.fold(Optional.none, () {
        return Optional.some(iterable);
      });
    });
  }

  Getter<Whole, Iterable<Part>> asGetter() {
    return Getter(get);
  }
}
