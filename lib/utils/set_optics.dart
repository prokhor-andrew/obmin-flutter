// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/optics/transformers/bi_preview.dart';
import 'package:obmin/optics/transformers/iso.dart';
import 'package:obmin/optics/transformers/prism.dart';
import 'package:obmin/optics/transformers/reflector.dart';
import 'package:obmin/types/optional.dart';

extension SetOpticsEqvExtension<T> on Eqv<Set<T>> {
  FoldSet<Set<T>, T> get folded => asGetter().folded;

  Preview<Set<T>, T> find(bool Function(T element) function) {
    return asGetter().find(function);
  }

  Getter<Set<T>, int> get length => asGetter().length;
}

extension SetOpticsGetterExtension<Whole, T> on Getter<Whole, Set<T>> {
  FoldSet<Whole, T> get folded => asPreview().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return asPreview().find(function);
  }

  Getter<Whole, int> get length => compose(Getter<Set<T>, int>((whole) => whole.length));
}

extension SetOpticsPreviewExtension<Whole, T> on Preview<Whole, Set<T>> {
  FoldSet<Whole, T> get folded => asFoldSet().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return compose(
      Preview<Set<T>, T>(
        (whole) {
          for (final element in whole) {
            if (function(element)) {
              return Optional.some(element);
            }
          }
          return Optional.none();
        },
      ),
    );
  }

  Preview<Whole, int> get length => composeWithGetter(Getter<Set<T>, int>((whole) => whole.length));
}

extension SetOpticsFoldSetExtension<Whole, T> on FoldSet<Whole, Set<T>> {
  FoldSet<Whole, T> get folded => compose(FoldSet<Set<T>, T>((whole) => whole));

  FoldSet<Whole, T> find(bool Function(T element) function) {
    return composeWithPreview(
      Preview<Set<T>, T>(
        (whole) {
          for (final element in whole) {
            if (function(element)) {
              return Optional.some(element);
            }
          }
          return Optional.none();
        },
      ),
    );
  }

  FoldSet<Whole, int> get length => composeWithGetter(Getter<Set<T>, int>((whole) => whole.length));
}

extension SetOpticsMutatorExtension<Whole, T> on Mutator<Whole, Set<T>> {
  Mutator<Whole, T> get traversed => compose(
        Mutator.traversalSet<Set<T>, T>(
          FoldSet<Set<T>, T>((whole) => whole),
          Getter((part) => Getter((_) => part.asSet())),
        ),
      );

  Mutator<Whole, T> find(bool Function(T element) function) {
    return compose(
      Mutator.affine(Preview<Set<T>, T>((whole) {
        for (final element in whole) {
          if (function(element)) {
            return Optional.some(element);
          }
        }
        return Optional.none();
      }), Getter(
        (part) {
          return Getter((whole) {
            final copy = whole.toList();
            final index = copy.indexWhere(function);
            if (index == -1) {
              return whole;
            }

            copy.removeAt(index);
            copy.insert(index, part);

            return copy.toSet();
          });
        },
      )),
    );
  }
}

extension SetOpticsIsoExtension<Whole, T> on Iso<Whole, Set<T>> {
  Mutator<Whole, T> get traversed => asMutator().traversed;

  Mutator<Whole, T> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension SetOpticsPrismExtension<Whole, T> on Prism<Whole, Set<T>> {
  Mutator<Whole, T> get traversed => asMutator().traversed;

  Mutator<Whole, T> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension SetOpticsReflectorExtension<Whole, T> on Reflector<Whole, Set<T>> {
  Mutator<Whole, T> get traversed => asMutator().traversed;

  Mutator<Whole, T> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension SetOpticsBiPreviewExtension<Whole, T> on BiPreview<Whole, Set<T>> {
  Mutator<Whole, T> get traversed => asMutator().traversed;

  Mutator<Whole, T> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}
