// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/fold.dart';
import 'package:obmin/optics/getter.dart';
import 'package:obmin/optics/preview.dart';
import 'package:obmin/optics/mutable/bi_preview.dart';
import 'package:obmin/optics/mutable/iso.dart';
import 'package:obmin/optics/mutable/prism.dart';
import 'package:obmin/optics/mutable/reflector.dart';
import 'package:obmin/types/update.dart';

final class Mutator<Whole, Part> {
  final Whole Function(Whole whole, Update<Part> update) apply;

  const Mutator(this.apply);

  Mutator<Whole, Sub> compose<Sub>(Mutator<Part, Sub> other) {
    return Mutator((whole, update) {
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
    return "Mutator<$Whole, $Part>";
  }

  static Mutator<Whole, Whole> setter<Whole>() {
    return Mutator((whole, modify) {
      return modify(whole);
    });
  }

  static Mutator<Whole, Part> lens<Whole, Part>(Getter<Whole, Part> get, Whole Function(Whole, Part) mutate) {
    return Mutator((whole, modify) {
      final part = modify(get.get(whole));
      return mutate(whole, part);
    });
  }

  static Mutator<Whole, Part> affine<Whole, Part>(Preview<Whole, Part> preview, Whole Function(Whole, Part) mutate) {
    return Mutator((whole, modify) {
      return preview.preview(whole).map(modify).map((part) {
        return mutate(whole, part);
      }).valueOr(whole);
    });
  }

  static Mutator<Whole, Part> traversal<Whole, Part>(Fold<Whole, Part> fold, Whole Function(Whole, Iterable<Part>) mutate) {
    return Mutator((whole, modify) {
      final list = fold.fold(whole).map(modify);
      return mutate(whole, list);
    });
  }

  Mutator<Whole, Sub> composeWithIso<Sub>(Iso<Part, Sub> other) {
    return compose(other.asMutator());
  }

  Mutator<Whole, Sub> composeWithPrism<Sub>(Prism<Part, Sub> other) {
    return compose(other.asMutator());
  }

  Mutator<Whole, Sub> composeWithReflector<Sub>(Reflector<Part, Sub> other) {
    return compose(other.asMutator());
  }

  Mutator<Whole, Sub> composeWithBiPreview<Sub>(BiPreview<Part, Sub> other) {
    return compose(other.asMutator());
  }
}

extension IsoAsMutatorExtension<T1, T2> on Iso<T1, T2> {
  Mutator<T1, T2> asMutator() {
    return Mutator(
      (whole, update) {
        final t2 = forward.get(whole);
        final updated = update(t2);
        return backward.get(updated);
      },
    );
  }
}

extension PrismAsMutatorExtension<Whole, Part> on Prism<Whole, Part> {
  Mutator<Whole, Part> asMutator() {
    return Mutator(
      (whole, update) {
        final partOrNone = tryGet.preview(whole);
        final updatedOrNone = partOrNone.map(update);
        return updatedOrNone.map(inject.get).valueOr(whole);
      },
    );
  }
}

extension ReflectorAsMutatorExtension<Whole, Part> on Reflector<Whole, Part> {
  Mutator<Whole, Part> asMutator() {
    return Mutator(
      (whole, update) {
        final part = getter.get(whole);
        final updated = update(part);
        return preview.preview(updated).valueOr(whole);
      },
    );
  }
}

extension BiPreviewAsMutatorExtension<T1, T2> on BiPreview<T1, T2> {
  Mutator<T1, T2> asMutator() {
    return Mutator(
      (whole, update) {
        final partOrNone = forward.preview(whole);
        final updatedOrNone = partOrNone.map(update);
        final wholeOrNone = updatedOrNone.bind(backward.preview);
        return wholeOrNone.valueOr(whole);
      },
    );
  }
}
