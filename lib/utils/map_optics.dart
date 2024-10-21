// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/fp/non_empty_map.dart';
import 'package:obmin/fp/optional.dart';
import 'package:obmin/fp/product.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_map.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

extension MapOpticsEqvExtension<Key, T> on Eqv<IMap<Key, T>> {
  FoldMap<IMap<Key, T>, Key, T> get folded => asGetter().folded;

  Preview<IMap<Key, T>, T> find(bool Function(T element) function) {
    return asGetter().find(function);
  }

  Getter<IMap<Key, T>, int> get length => asGetter().length;
}

extension MapOpticsGetterExtension<Whole, Key, T> on Getter<Whole, IMap<Key, T>> {
  FoldMap<Whole, Key, T> get folded => asPreview().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return asPreview().find(function);
  }

  Getter<Whole, int> get length => compose(Getter((map) => map.length));
}

extension MapOpticsPreviewExtension<Whole, Key, T> on Preview<Whole, IMap<Key, T>> {
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
          return const Optional.none();
        },
      ),
    );
  }

  Preview<Whole, int> get length => composeWithGetter(Getter((map) => map.length));
}

extension MapOpticsFoldSetExtension<Whole, Key, T> on FoldSet<Whole, IMap<Key, T>> {
  FoldMap<Whole, Key, T> get folded => compose(FoldSet((map) {
        return map.toISetOfProducts();
      }));

  FoldSet<Whole, T> find(bool Function(T element) function) {
    return composeWithPreview(
      Preview<IMap<Key, T>, T>(
        (whole) {
          for (final element in whole.values) {
            if (function(element)) {
              return Optional.some(element);
            }
          }
          return const Optional.none();
        },
      ),
    );
  }

  FoldSet<Whole, int> get length => composeWithGetter(Getter((map) => map.length));
}

extension MapOpticsMutatorExtension<Whole, Key, T> on Mutator<Whole, IMap<Key, T>> {
  Mutator<Whole, Product<Key, T>> get traversed => compose(
        Mutator.traversalSet<IMap<Key, T>, Product<Key, T>>(
          FoldMap<IMap<Key, T>, Key, T>((whole) => whole.toISetOfProducts()),
          Getter((part) => Getter((_) => part.fromSetOfProductToMap().toIMap())),
        ),
      );

  Mutator<Whole, Product<Key, T>> find(bool Function(T element) function) {
    return compose(
      Mutator.affine(
        Preview<IMap<Key, T>, Product<Key, T>>(
          (whole) {
            for (final entry in whole.entries) {
              if (function(entry.value)) {
                return Optional.some(Product(entry.key, entry.value));
              }
            }

            return const Optional.none();
          },
        ),
        Getter(
          (part) {
            return Getter(
              (whole) {
                return whole.add(part.left, part.right);
              },
            );
          },
        ),
      ),
    );
  }
}
