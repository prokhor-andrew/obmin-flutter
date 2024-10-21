// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/fp/non_empty_set.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

extension NonEmptySetOpticsEqvExtension<T> on Eqv<NonEmptySet<T>> {
  FoldSet<NonEmptySet<T>, T> get folded => asGetter().folded;

  Preview<NonEmptySet<T>, T> find(bool Function(T element) function) {
    return asGetter().find(function);
  }

  Getter<NonEmptySet<T>, int> get length => asGetter().length;
}

extension SetOpticsGetterExtension<Whole, T> on Getter<Whole, NonEmptySet<T>> {
  FoldSet<Whole, T> get folded => asPreview().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return asPreview().find(function);
  }

  Getter<Whole, int> get length => compose(Getter<NonEmptySet<T>, int>((whole) => whole.length));
}

extension SetOpticsPreviewExtension<Whole, T> on Preview<Whole, NonEmptySet<T>> {
  FoldSet<Whole, T> get folded => asFoldSet().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return compose(
      Preview<NonEmptySet<T>, T>(
        (whole) {
          return whole.findWhere(function);
        },
      ),
    );
  }

  Preview<Whole, int> get length => composeWithGetter(Getter<NonEmptySet<T>, int>((whole) => whole.length));
}

extension SetOpticsFoldSetExtension<Whole, T> on FoldSet<Whole, NonEmptySet<T>> {
  FoldSet<Whole, T> get folded => compose(FoldSet<NonEmptySet<T>, T>((whole) => whole.toISet()));

  FoldSet<Whole, T> find(bool Function(T element) function) {
    return composeWithPreview(
      Preview<NonEmptySet<T>, T>(
        (whole) {
          return whole.findWhere(function);
        },
      ),
    );
  }

  FoldSet<Whole, int> get length => composeWithGetter(Getter<NonEmptySet<T>, int>((whole) => whole.length));
}

extension SetOpticsMutatorExtension<Whole, T> on Mutator<Whole, NonEmptySet<T>> {
  Mutator<Whole, T> get traversed => compose(
        Mutator.traversalSet<NonEmptySet<T>, T>(
          FoldSet<NonEmptySet<T>, T>((whole) => whole.toISet()),
          Getter((part) => Getter((_) => part)),
        ),
      );

  Mutator<Whole, T> find(bool Function(T element) function) {
    return compose(
      Mutator.affine(Preview<NonEmptySet<T>, T>((whole) {
        return whole.findWhere(function);
      }), Getter(
        (part) {
          return Getter((whole) {
            return whole.removeWhere(function).valueOr(whole);
          });
        },
      )),
    );
  }
}
