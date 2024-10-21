// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/fp/non_empty_list.dart';
import 'package:obmin/fp/optional.dart';
import 'package:obmin/fp/product.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_list.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

extension ListOpticsEqvExtension<T> on Eqv<IList<T>> {
  FoldList<IList<T>, T> get folded => asGetter().folded;

  Preview<IList<T>, T> find(bool Function(T element) function) {
    return asGetter().find(function);
  }

  Getter<IList<T>, int> get length => asGetter().length;
}

extension ListOpticsGetterExtension<Whole, T> on Getter<Whole, IList<T>> {
  FoldList<Whole, T> get folded => asPreview().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return asPreview().find(function);
  }

  Getter<Whole, int> get length => compose(Getter((list) => list.length));
}

extension ListOpticsPreviewExtension<Whole, T> on Preview<Whole, IList<T>> {
  FoldList<Whole, T> get folded => asFoldSet().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return compose(
      Preview(
        (whole) {
          for (final element in whole) {
            if (function(element)) {
              return Optional.some(element);
            }
          }
          return const Optional.none();
        },
      ),
    );
  }

  Preview<Whole, int> get length => composeWithGetter(Getter((list) => list.length));
}

extension ListOpticsFoldSetExtension<Whole, T> on FoldSet<Whole, IList<T>> {
  FoldList<Whole, T> get folded => compose(FoldSet((list) {
        return list.toISetOfProducts();
      }));

  FoldSet<Whole, T> find(bool Function(T element) function) {
    return composeWithPreview(
      Preview<IList<T>, T>(
        (whole) {
          for (final element in whole) {
            if (function(element)) {
              return Optional.some(element);
            }
          }
          return const Optional.none();
        },
      ),
    );
  }

  FoldSet<Whole, int> get length => composeWithGetter(Getter((list) => list.length));
}

extension ListOpticsMutatorExtension<Whole, T> on Mutator<Whole, IList<T>> {
  Mutator<Whole, Product<int, T>> get traversed => compose(
        Mutator.traversalSet<IList<T>, Product<int, T>>(
          FoldList<IList<T>, T>((whole) => whole.toISetOfProducts()),
          Getter((part) => Getter((_) => part.fromSetOfProductToList().toIList())),
        ),
      );

  Mutator<Whole, Product<int, T>> find(bool Function(T element) function) {
    return compose(
      Mutator.affine(
        Preview<IList<T>, Product<int, T>>(
          (whole) {
            for (int i = 0; i < whole.length; i++) {
              final element = whole[i];
              if (function(element)) {
                return Optional.some(Product(i, element));
              }
            }

            return const Optional.none();
          },
        ),
        Getter(
          (part) {
            return Getter(
              (whole) {
                return whole.removeAt(part.left).insert(part.left, part.right);
              },
            );
          },
        ),
      ),
    );
  }
}
