// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_list.dart';
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

extension ListOpticsEqvExtension<T> on Eqv<List<T>> {
  FoldList<List<T>, T> get folded => asGetter().folded;

  Preview<List<T>, T> find(bool Function(T element) function) {
    return asGetter().find(function);
  }

  Getter<List<T>, int> get length => asGetter().length;
}

extension ListOpticsGetterExtension<Whole, T> on Getter<Whole, List<T>> {
  FoldList<Whole, T> get folded => asPreview().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return asPreview().find(function);
  }

  Getter<Whole, int> get length => compose(Getter((list) => list.length));
}

extension ListOpticsPreviewExtension<Whole, T> on Preview<Whole, List<T>> {
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
          return Optional.none();
        },
      ),
    );
  }

  Preview<Whole, int> get length => composeWithGetter(Getter((list) => list.length));
}

extension ListOpticsFoldSetExtension<Whole, T> on FoldSet<Whole, List<T>> {
  FoldList<Whole, T> get folded => compose(FoldSet((list) {
        return list.asSetOfProduct();
      }));

  FoldSet<Whole, T> find(bool Function(T element) function) {
    return composeWithPreview(
      Preview<List<T>, T>(
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

  FoldSet<Whole, int> get length => composeWithGetter(Getter((list) => list.length));
}

extension ListOpticsMutatorExtension<Whole, T> on Mutator<Whole, List<T>> {
  Mutator<Whole, Product<int, T>> get traversed => compose(
        Mutator.traversalSet<List<T>, Product<int, T>>(
          FoldList<List<T>, T>((whole) => whole.asSetOfProduct()),
          Getter((part) => Getter((_) => part.fromSetOfProductToList().asList())),
        ),
      );

  Mutator<Whole, Product<int, T>> find(bool Function(T element) function) {
    return compose(
      Mutator.affine(
        Preview<List<T>, Product<int, T>>(
          (whole) {
            for (int i = 0; i < whole.length; i++) {
              final element = whole[i];
              if (function(element)) {
                return Optional.some(Product(i, element));
              }
            }

            return Optional.none();
          },
        ),
        Getter(
          (part) {
            return Getter(
              (whole) {
                final copy = whole.toList();

                copy.removeAt(part.value1);
                copy.insert(part.value1, part.value2);

                return copy;
              },
            );
          },
        ),
      ),
    );
  }
}

extension ListOpticsIsoExtension<Whole, T> on Iso<Whole, List<T>> {
  Mutator<Whole, Product<int, T>> get traversed => asMutator().traversed;

  Mutator<Whole, Product<int, T>> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension ListOpticsPrismExtension<Whole, T> on Prism<Whole, List<T>> {
  Mutator<Whole, Product<int, T>> get traversed => asMutator().traversed;

  Mutator<Whole, Product<int, T>> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension ListOpticsReflectorExtension<Whole, T> on Reflector<Whole, List<T>> {
  Mutator<Whole, Product<int, T>> get traversed => asMutator().traversed;

  Mutator<Whole, Product<int, T>> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension ListOpticsBiPreviewExtension<Whole, T> on BiPreview<Whole, List<T>> {
  Mutator<Whole, Product<int, T>> get traversed => asMutator().traversed;

  Mutator<Whole, Product<int, T>> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}
