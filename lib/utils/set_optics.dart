// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/fp/optional.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

extension SetOpticsEqvExtension<T> on Eqv<ISet<T>> {
  FoldSet<ISet<T>, T> get folded => asGetter().folded;

  Preview<ISet<T>, T> find(bool Function(T element) function) {
    return asGetter().find(function);
  }

  Getter<ISet<T>, int> get length => asGetter().length;
}

extension SetOpticsGetterExtension<Whole, T> on Getter<Whole, ISet<T>> {
  FoldSet<Whole, T> get folded => asPreview().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return asPreview().find(function);
  }

  Getter<Whole, int> get length => compose(Getter<ISet<T>, int>((whole) => whole.length));
}

extension SetOpticsPreviewExtension<Whole, T> on Preview<Whole, ISet<T>> {
  FoldSet<Whole, T> get folded => asFoldSet().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return compose(
      Preview<ISet<T>, T>(
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

  Preview<Whole, int> get length => composeWithGetter(Getter<ISet<T>, int>((whole) => whole.length));
}

extension SetOpticsFoldSetExtension<Whole, T> on FoldSet<Whole, ISet<T>> {
  FoldSet<Whole, T> get folded => compose(FoldSet<ISet<T>, T>((whole) => whole));

  FoldSet<Whole, T> find(bool Function(T element) function) {
    return composeWithPreview(
      Preview<ISet<T>, T>(
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

  FoldSet<Whole, int> get length => composeWithGetter(Getter<ISet<T>, int>((whole) => whole.length));
}

extension SetOpticsMutatorExtension<Whole, T> on Mutator<Whole, ISet<T>> {
  Mutator<Whole, T> get traversed => compose(
        Mutator.traversalSet<ISet<T>, T>(
          FoldSet<ISet<T>, T>((whole) => whole),
          Getter((part) => Getter((_) => part.toISet())),
        ),
      );

  Mutator<Whole, T> find(bool Function(T element) function) {
    return compose(
      Mutator.affine(Preview<ISet<T>, T>((whole) {
        for (final element in whole) {
          if (function(element)) {
            return Optional.some(element);
          }
        }
        return const Optional.none();
      }), Getter(
        (part) {
          return Getter((whole) {
            return whole.removeWhere(function);
          });
        },
      )),
    );
  }
}
