// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_map.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/optics/transformers/bi_preview.dart';
import 'package:obmin/optics/transformers/iso.dart';
import 'package:obmin/optics/transformers/prism.dart';
import 'package:obmin/optics/transformers/reflector.dart';
import 'package:obmin/types/optional.dart';
import 'package:obmin/types/product.dart';
import 'package:obmin/utils/as_set.dart';

extension MapOpticsEqvExtension<Key, T> on Eqv<Map<Key, T>> {
  FoldMap<Map<Key, T>, Key, T> get folded => asGetter().folded;

  Preview<Map<Key, T>, T> find(bool Function(T element) function) {
    return asGetter().find(function);
  }

  Getter<Map<Key, T>, int> get length => asGetter().length;
}

extension MapOpticsGetterExtension<Whole, Key, T> on Getter<Whole, Map<Key, T>> {
  FoldMap<Whole, Key, T> get folded => asPreview().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return asPreview().find(function);
  }

  Getter<Whole, int> get length => compose(Getter((map) => map.length));
}

extension MapOpticsPreviewExtension<Whole, Key, T> on Preview<Whole, Map<Key, T>> {
  FoldMap<Whole, Key, T> get folded => asFoldSet().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return compose(
      Preview(
        (whole) {
          for (final element in whole.values) {
            if (function(element)) {
              return Optional.some(element);
            }
          }
          return Optional.none();
        },
      ),
    );
  }

  Preview<Whole, int> get length => composeWithGetter(Getter((map) => map.length));
}

extension MapOpticsFoldSetExtension<Whole, Key, T> on FoldSet<Whole, Map<Key, T>> {
  FoldMap<Whole, Key, T> get folded => compose(FoldSet((map) {
        return map.asSetOfProduct();
      }));

  FoldSet<Whole, T> find(bool Function(T element) function) {
    return composeWithPreview(
      Preview<Map<Key, T>, T>(
        (whole) {
          for (final element in whole.values) {
            if (function(element)) {
              return Optional.some(element);
            }
          }
          return Optional.none();
        },
      ),
    );
  }

  FoldSet<Whole, int> get length => composeWithGetter(Getter((map) => map.length));
}

extension MapOpticsMutatorExtension<Whole, Key, T> on Mutator<Whole, Map<Key, T>> {
  Mutator<Whole, Product<Key, T>> get traversed => compose(
        Mutator.traversalSet<Map<Key, T>, Product<Key, T>>(
          FoldMap<Map<Key, T>, Key, T>((whole) => whole.asSetOfProduct()),
          Getter((part) => Getter((_) => part.fromSetOfProductToMap().asMap())),
        ),
      );

  Mutator<Whole, Product<Key, T>> find(bool Function(T element) function) {
    return compose(
      Mutator.affine(
        Preview<Map<Key, T>, Product<Key, T>>(
          (whole) {
            for (final entry in whole.entries) {
              if (function(entry.value)) {
                return Optional.some(Product(entry.key, entry.value));
              }
            }

            return Optional.none();
          },
        ),
        Getter(
          (part) {
            return Getter(
              (whole) {
                final copy = Map<Key, T>.from(whole);

                copy[part.value1] = part.value2;

                return copy;
              },
            );
          },
        ),
      ),
    );
  }
}

extension MapOpticsIsoExtension<Whole, Key, T> on Iso<Whole, Map<Key, T>> {
  Mutator<Whole, Product<Key, T>> get traversed => asMutator().traversed;

  Mutator<Whole, Product<Key, T>> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension MapOpticsPrismExtension<Whole, Key, T> on Prism<Whole, Map<Key, T>> {
  Mutator<Whole, Product<Key, T>> get traversed => asMutator().traversed;

  Mutator<Whole, Product<Key, T>> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension MapOpticsReflectorExtension<Whole, Key, T> on Reflector<Whole, Map<Key, T>> {
  Mutator<Whole, Product<Key, T>> get traversed => asMutator().traversed;

  Mutator<Whole, Product<Key, T>> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension MapOpticsBiPreviewExtension<Whole, Key, T> on BiPreview<Whole, Map<Key, T>> {
  Mutator<Whole, Product<Key, T>> get traversed => asMutator().traversed;

  Mutator<Whole, Product<Key, T>> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}
