// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/fold.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/optics/transformers/bi_eqv.dart';
import 'package:obmin/optics/transformers/bi_preview.dart';
import 'package:obmin/optics/transformers/iso.dart';
import 'package:obmin/optics/transformers/prism.dart';
import 'package:obmin/optics/transformers/reflector.dart';
import 'package:obmin/types/non_empty_iterable.dart';
import 'package:obmin/types/update.dart';

final class Mutator<Whole, Part> {
  final Getter<Update<Part>, Update<Whole>> applier;

  const Mutator(this.applier);

  Mutator<Whole, Sub> compose<Sub>(Mutator<Part, Sub> other) {
    return Mutator(Getter((update) {
      return Getter((whole) {
        return applier.get(Getter((part) {
          return other.applier.get(update).get(part);
        })).get(whole);
      });
    }));
  }

  Update<Whole> apply(Part Function(Part part) update) {
    return applier.get(Getter(update));
  }

  Update<Whole> set(Part part) {
    return applier.get(Update((_) => part));
  }

  @override
  String toString() {
    return "Mutator<$Whole, $Part>";
  }

  static Mutator<Whole, Whole> reducer<Whole>() {
    return Mutator(Getter((modify) {
      return Getter(modify.get);
    }));
  }

  static Mutator<Whole, Part> lens<Whole, Part>(
    Getter<Whole, Part> get,
    Getter<Part, Update<Whole>> reconstruct,
  ) {
    return Mutator(Getter((modify) {
      return Getter((whole) {
        final zoomed = get.get(whole);
        final modified = modify.get(zoomed);
        return reconstruct.get(modified).get(whole);
      });
    }));
  }

  static Mutator<Whole, Part> affine<Whole, Part>(
    Preview<Whole, Part> preview,
    Getter<Part, Update<Whole>> reconstruct,
  ) {
    return Mutator(Getter((modify) {
      return Getter((whole) {
        return preview.get(whole).map(modify.get).map((part) {
          return reconstruct.get(part).get(whole);
        }).valueOr(whole);
      });
    }));
  }

  static Mutator<Whole, Part> traversal<Whole, Part>(
    Fold<Whole, Part> fold,
    Getter<NonEmptyIterable<Part>, Update<Whole>> reconstruct,
  ) {
    return Mutator(Getter((modify) {
      return Getter((whole) {
        final zoomedOrNone = NonEmptyIterable.fromIterable(fold.get(whole));
        return zoomedOrNone.map((zoomed) {
          final modified = zoomed.map(modify.get);
          return reconstruct.get(modified).get(whole);
        }).valueOr(whole);
      });
    }));
  }

  Mutator<Whole, Part> composeWithBiEqv(BiEqv<Part> other) {
    return compose(other.asMutator());
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

extension BiEqvAsMutatorExtension<T> on BiEqv<T> {
  Mutator<T, T> asMutator() {
    return asIso().asMutator();
  }
}

extension IsoAsMutatorExtension<T1, T2> on Iso<T1, T2> {
  Mutator<T1, T2> asMutator() {
    return asBiPreview().asMutator();
  }
}

extension PrismAsMutatorExtension<Whole, Part> on Prism<Whole, Part> {
  Mutator<Whole, Part> asMutator() {
    return asBiPreview().asMutator();
  }
}

extension ReflectorAsMutatorExtension<Whole, Part> on Reflector<Whole, Part> {
  Mutator<Whole, Part> asMutator() {
    return asBiPreview().asMutator();
  }
}

extension BiPreviewAsMutatorExtension<T1, T2> on BiPreview<T1, T2> {
  Mutator<T1, T2> asMutator() {
    return Mutator(Getter(
      (update) {
        return Getter((whole) {
          final partOrNone = forward.get(whole);
          final updatedOrNone = partOrNone.map(update.get);
          final wholeOrNone = updatedOrNone.bind(backward.get);
          return wholeOrNone.valueOr(whole);
        });
      },
    ));
  }
}
