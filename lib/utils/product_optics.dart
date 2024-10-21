// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/fp/product.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

extension ProductObminOpticEqvExtension<T1, T2> on Eqv<Product<T1, T2>> {
  Getter<Product<T1, T2>, T1> get left => asGetter().left;

  Getter<Product<T1, T2>, T2> get right => asGetter().right;
}

extension ProductObminOpticGetterExtension<Whole, T1, T2> on Getter<Whole, Product<T1, T2>> {
  Getter<Whole, T1> get left => compose(Getter<Product<T1, T2>, T1>((whole) => whole.left));

  Getter<Whole, T2> get right => compose(Getter<Product<T1, T2>, T2>((whole) => whole.right));
}

extension ProductObminOpticPreviewExtension<Whole, T1, T2> on Preview<Whole, Product<T1, T2>> {
  Preview<Whole, T1> get left => composeWithGetter(Getter<Product<T1, T2>, T1>((whole) => whole.left));

  Preview<Whole, T2> get right => composeWithGetter(Getter<Product<T1, T2>, T2>((whole) => whole.right));
}

extension ProductObminOpticFoldSetExtension<Whole, T1, T2> on FoldSet<Whole, Product<T1, T2>> {
  FoldSet<Whole, T1> get left => composeWithGetter(Getter<Product<T1, T2>, T1>((whole) => whole.left));

  FoldSet<Whole, T2> get right => composeWithGetter(Getter<Product<T1, T2>, T2>((whole) => whole.right));
}

extension ProductObminOpticMutatorExtension<Whole, T1, T2> on Mutator<Whole, Product<T1, T2>> {
  Mutator<Whole, T1> get left => compose(
        Mutator.lens<Product<T1, T2>, T1>(
          Getter<Product<T1, T2>, T1>((whole) => whole.left),
          Getter((part) => Getter((whole) => whole.mapLeftTo(part))),
        ),
      );

  Mutator<Whole, T2> get right => compose(
        Mutator.lens<Product<T1, T2>, T2>(
          Getter<Product<T1, T2>, T2>((whole) => whole.right),
          Getter((part) => Getter((whole) => whole.mapRightTo(part))),
        ),
      );
}
