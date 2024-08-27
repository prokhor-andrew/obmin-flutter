// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/optics/transformers/bi_preview.dart';
import 'package:obmin/optics/transformers/iso.dart';
import 'package:obmin/optics/transformers/prism.dart';
import 'package:obmin/optics/transformers/reflector.dart';

final class Product<T1, T2> {
  final T1 value1;
  final T2 value2;

  const Product(
    this.value1,
    this.value2,
  );

  Product<T2, T1> swapped() {
    return Product(value2, value1);
  }

  @override
  String toString() {
    return "Product<$T1,$T2> { value1=$value1, value2=$value2 }";
  }

  // you need "collection:" package if you want to use Iterable in your class
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product<T1, T2> && other.value1 == value1 && other.value2 == value2;
  }

  @override
  int get hashCode => Object.hashAll([
        value1,
        value2,
      ]);

  static Eqv<Product<T1, T2>> eqv<T1, T2>() => Eqv<Product<T1, T2>>();

  static Mutator<Product<T1, T2>, Product<T1, T2>> reducer<T1, T2>() => Mutator.reducer<Product<T1, T2>>();
}

extension ProductObminOpticToolMethodsExtension<T1, T2> on Product<T1, T2> {
  Product<T1, T2> mapValue1(T1 Function(T1 value1) function) {
    return Product(
      function(value1),
      value2,
    );
  }

  Product<T1, T2> mapValue1To(T1 value1) {
    return mapValue1((_) => value1);
  }

  Product<T1, T2> mapValue2(T2 Function(T2 value2) function) {
    return Product(
      value1,
      function(value2),
    );
  }

  Product<T1, T2> mapValue2To(T2 value2) {
    return mapValue2((_) => value2);
  }

  R fold<R>(
    R Function(Product<T1, T2>) function,
  ) {
    return function(this);
  }
}

extension ProductObminOpticEqvExtension<T1, T2> on Eqv<Product<T1, T2>> {
  Getter<Product<T1, T2>, T1> get value1 => asGetter().value1;

  Getter<Product<T1, T2>, T2> get value2 => asGetter().value2;
}

extension ProductObminOpticGetterExtension<Whole, T1, T2> on Getter<Whole, Product<T1, T2>> {
  Getter<Whole, T1> get value1 => compose(Getter<Product<T1, T2>, T1>((whole) => whole.value1));

  Getter<Whole, T2> get value2 => compose(Getter<Product<T1, T2>, T2>((whole) => whole.value2));
}

extension ProductObminOpticPreviewExtension<Whole, T1, T2> on Preview<Whole, Product<T1, T2>> {
  Preview<Whole, T1> get value1 => composeWithGetter(Getter<Product<T1, T2>, T1>((whole) => whole.value1));

  Preview<Whole, T2> get value2 => composeWithGetter(Getter<Product<T1, T2>, T2>((whole) => whole.value2));
}

extension ProductObminOpticFoldExtension<Whole, T1, T2> on Fold<Whole, Product<T1, T2>> {
  Fold<Whole, T1> get value1 => composeWithGetter(Getter<Product<T1, T2>, T1>((whole) => whole.value1));

  Fold<Whole, T2> get value2 => composeWithGetter(Getter<Product<T1, T2>, T2>((whole) => whole.value2));
}

extension ProductObminOpticMutatorExtension<Whole, T1, T2> on Mutator<Whole, Product<T1, T2>> {
  Mutator<Whole, T1> get value1 => compose(
        Mutator.lens<Product<T1, T2>, T1>(
          Getter<Product<T1, T2>, T1>((whole) => whole.value1),
          Getter((part) => Getter((whole) => whole.mapValue1To(part))),
        ),
      );

  Mutator<Whole, T2> get value2 => compose(
        Mutator.lens<Product<T1, T2>, T2>(
          Getter<Product<T1, T2>, T2>((whole) => whole.value2),
          Getter((part) => Getter((whole) => whole.mapValue2To(part))),
        ),
      );
}

extension ProductObminOpticIsoExtension<Whole, T1, T2> on Iso<Whole, Product<T1, T2>> {
  Mutator<Whole, T1> get value1 => asMutator().compose(
        Mutator.lens<Product<T1, T2>, T1>(
          Getter<Product<T1, T2>, T1>((whole) => whole.value1),
          Getter((part) => Getter((whole) => whole.mapValue1To(part))),
        ),
      );

  Mutator<Whole, T2> get value2 => asMutator().compose(
        Mutator.lens<Product<T1, T2>, T2>(
          Getter<Product<T1, T2>, T2>((whole) => whole.value2),
          Getter((part) => Getter((whole) => whole.mapValue2To(part))),
        ),
      );
}

extension ProductObminOpticPrismExtension<Whole, T1, T2> on Prism<Whole, Product<T1, T2>> {
  Mutator<Whole, T1> get value1 => asMutator().compose(
        Mutator.lens<Product<T1, T2>, T1>(
          Getter<Product<T1, T2>, T1>((whole) => whole.value1),
          Getter((part) => Getter((whole) => whole.mapValue1To(part))),
        ),
      );

  Mutator<Whole, T2> get value2 => asMutator().compose(
        Mutator.lens<Product<T1, T2>, T2>(
          Getter<Product<T1, T2>, T2>((whole) => whole.value2),
          Getter((part) => Getter((whole) => whole.mapValue2To(part))),
        ),
      );
}

extension ProductObminOpticReflectorExtension<Whole, T1, T2> on Reflector<Whole, Product<T1, T2>> {
  Mutator<Whole, T1> get value1 => asMutator().compose(
        Mutator.lens<Product<T1, T2>, T1>(
          Getter<Product<T1, T2>, T1>((whole) => whole.value1),
          Getter((part) => Getter((whole) => whole.mapValue1To(part))),
        ),
      );

  Mutator<Whole, T2> get value2 => asMutator().compose(
        Mutator.lens<Product<T1, T2>, T2>(
          Getter<Product<T1, T2>, T2>((whole) => whole.value2),
          Getter((part) => Getter((whole) => whole.mapValue2To(part))),
        ),
      );
}

extension ProductObminOpticBiPreviewExtension<Whole, T1, T2> on BiPreview<Whole, Product<T1, T2>> {
  Mutator<Whole, T1> get value1 => asMutator().compose(
        Mutator.lens<Product<T1, T2>, T1>(
          Getter<Product<T1, T2>, T1>((whole) => whole.value1),
          Getter((part) => Getter((whole) => whole.mapValue1To(part))),
        ),
      );

  Mutator<Whole, T2> get value2 => asMutator().compose(
        Mutator.lens<Product<T1, T2>, T2>(
          Getter<Product<T1, T2>, T2>((whole) => whole.value2),
          Getter((part) => Getter((whole) => whole.mapValue2To(part))),
        ),
      );
}
