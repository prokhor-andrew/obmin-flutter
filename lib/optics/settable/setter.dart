// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/fold.dart';
import 'package:obmin/optics/getter.dart';
import 'package:obmin/optics/preview.dart';
import 'package:obmin/optics/settable/bi_preview.dart';
import 'package:obmin/optics/settable/iso.dart';
import 'package:obmin/optics/settable/prism.dart';
import 'package:obmin/optics/settable/reflector.dart';
import 'package:obmin/types/update.dart';

final class Setter<Whole, Part> {
  final Whole Function(Whole whole, Update<Part> update) apply;

  const Setter(this.apply);

  Setter<Whole, Sub> compose<Sub>(Setter<Part, Sub> other) {
    return Setter((whole, update) {
      return apply(whole, (part) {
        return other.apply(part, update);
      });
    });
  }

  Whole set(Whole whole, Part part) {
    return apply(whole, (_) => part);
  }

  @override
  String toString() {
    return "Setter<$Whole, $Part>";
  }

  static Setter<Whole, Part> lens<Whole, Part>(Getter<Whole, Part> get, Whole Function(Whole, Part) set) {
    return Setter((whole, modify) {
      final part = modify(get.get(whole));
      return set(whole, part);
    });
  }

  static Setter<Whole, Part> affine<Whole, Part>(Preview<Whole, Part> preview, Whole Function(Whole, Part) set) {
    return Setter((whole, modify) {
      return preview.preview(whole).map(modify).map((part) {
        return set(whole, part);
      }).valueOr(whole);
    });
  }

  static Setter<Whole, Part> traversal<Whole, Part>(Fold<Whole, Part> fold, Whole Function(Whole, Iterable<Part>) set) {
    return Setter((whole, modify) {
      final list = fold.fold(whole).map(modify);
      return set(whole, list);
    });
  }

  Setter<Whole, Sub> composeWithIso<Sub>(Iso<Part, Sub> other) {
    return compose(other.asSetter());
  }

  Setter<Whole, Sub> composeWithPrism<Sub>(Prism<Part, Sub> other) {
    return compose(other.asSetter());
  }

  Setter<Whole, Sub> composeWithReflector<Sub>(Reflector<Part, Sub> other) {
    return compose(other.asSetter());
  }

  Setter<Whole, Sub> composeWithBiPreview<Sub>(BiPreview<Part, Sub> other) {
    return compose(other.asSetter());
  }
}

extension IsoAsSetterExtension<T1, T2> on Iso<T1, T2> {
  Setter<T1, T2> asSetter() {
    return Setter(
      (whole, update) {
        final t2 = forward.get(whole);
        final updated = update(t2);
        return backward.get(updated);
      },
    );
  }
}

extension PrismAsSetterExtension<Whole, Part> on Prism<Whole, Part> {
  Setter<Whole, Part> asSetter() {
    return Setter(
      (whole, update) {
        final partOrNone = tryGet.preview(whole);
        final updatedOrNone = partOrNone.map(update);
        return updatedOrNone.map(inject.get).valueOr(whole);
      },
    );
  }
}

extension ReflectorAsSetterExtension<Whole, Part> on Reflector<Whole, Part> {
  Setter<Whole, Part> asSetter() {
    return Setter(
      (whole, update) {
        final part = getter.get(whole);
        final updated = update(part);
        return preview.preview(updated).valueOr(whole);
      },
    );
  }
}

extension BiPreviewAsSetterExtension<T1, T2> on BiPreview<T1, T2> {
  Setter<T1, T2> asSetter() {
    return Setter(
      (whole, update) {
        final partOrNone = forward.preview(whole);
        final updatedOrNone = partOrNone.map(update);
        final wholeOrNone = updatedOrNone.bind(backward.preview);
        return wholeOrNone.valueOr(whole);
      },
    );
  }
}
