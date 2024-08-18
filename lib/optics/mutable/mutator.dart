// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/transformers/bi_eqv.dart';
import 'package:obmin/optics/transformers/bi_preview.dart';
import 'package:obmin/optics/transformers/iso.dart';
import 'package:obmin/optics/transformers/prism.dart';
import 'package:obmin/optics/transformers/reflector.dart';
import 'package:obmin/optics/readonly/fold.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/types/update.dart';
import 'package:obmin/utils/function_args_swapped.dart';
import 'package:obmin/utils/function_curry.dart';

final class Mutator<Whole, Part> {
  final Whole Function(Whole whole, Update<Part> update) apply;

  const Mutator(this.apply);

  Whole Function(Whole) Function(Update<Part> update) get curriedApply => apply.argsSwapped.curried;

  Whole Function(Whole) Function(Part part) get curriedSet => set.argsSwapped.curried;

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

  static Mutator<Whole, Whole> reducer<Whole>() {
    return Mutator((whole, modify) {
      return modify(whole);
    });
  }

  static Mutator<Whole, Part> lens<Whole, Part>(Getter<Whole, Part> get, Whole Function(Whole, Part) reconstruct) {
    return Mutator((whole, modify) {
      final part = modify(get.get(whole));
      return reconstruct(whole, part);
    });
  }

  static Mutator<Whole, Part> affine<Whole, Part>(Preview<Whole, Part> preview, Whole Function(Whole, Part) reconstruct) {
    return Mutator((whole, modify) {
      return preview.preview(whole).map(modify).map((part) {
        return reconstruct(whole, part);
      }).valueOr(whole);
    });
  }

  static Mutator<Whole, Part> traversal<Whole, Part>(Fold<Whole, Part> fold, Whole Function(Whole, Iterable<Part>) reconstruct) {
    return Mutator((whole, modify) {
      final list = fold.fold(whole).map(modify);
      return reconstruct(whole, list);
    });
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
