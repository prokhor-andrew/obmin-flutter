// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/fp/product.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

extension ListOpticsEqvExtension<T> on Eqv<IList<T>> {
  Getter<IList<T>, ISet<Product<int, T>>> get asSetOfProducts => asGetter().asSetOfProducts;
}

extension ListOpticsGetterExtension<Whole, T> on Getter<Whole, IList<T>> {
  Getter<Whole, ISet<Product<int, T>>> get asSetOfProducts => compose(Getter((whole) {
        ISet<Product<int, T>> set = const ISet.empty();

        for (int i = 0; i < whole.length; i++) {
          set = set.add(Product(i, whole[i]));
        }

        return set;
      }));
}

extension ListOpticsPreviewExtension<Whole, T> on Preview<Whole, IList<T>> {
  Preview<Whole, ISet<Product<int, T>>> get asSetOfProducts => composeWithGetter(Getter((whole) {
        ISet<Product<int, T>> set = const ISet.empty();

        for (int i = 0; i < whole.length; i++) {
          set = set.add(Product(i, whole[i]));
        }

        return set;
      }));
}

extension ListOpticsFoldSetExtension<Whole, T> on FoldSet<Whole, IList<T>> {
  FoldSet<Whole, ISet<Product<int, T>>> get asSetOfProducts => composeWithGetter(Getter((whole) {
        ISet<Product<int, T>> set = const ISet.empty();

        for (int i = 0; i < whole.length; i++) {
          set = set.add(Product(i, whole[i]));
        }

        return set;
      }));
}

extension ListOpticsMutatorExtension<Whole, T> on Mutator<Whole, IList<T>> {
  Mutator<Whole, ISet<Product<int, T>>> get asSetOfProducts => compose(Mutator.iso(
        Getter((whole) {
          ISet<Product<int, T>> set = const ISet.empty();

          for (int i = 0; i < whole.length; i++) {
            set = set.add(Product(i, whole[i]));
          }

          return set;
        }),
        Getter(
          (whole) {
            IList<T> result = const IList.empty();
            for (int i = 0; i < whole.length; i++) {
              final product = whole[i];
              final index = product.left;
              final item = product.right;

              if (index < result.length) {
                result = result.insert(index, item);
              } else {
                result = result.add(item);
              }
            }

            return result;
          },
        ),
      ));
}
