// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/fp/identity.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

extension IdentityOpticsEqvExtension<T> on Eqv<Identity<T>> {
  Getter<Identity<T>, T> get value => asGetter().value;
}

extension IdentityOpticsGetterExtension<Whole, T> on Getter<Whole, Identity<T>> {
  Getter<Whole, T> get value => compose(Getter((v) => v.value));
}

extension IdentityOpticsPreviewExtension<Whole, T> on Preview<Whole, Identity<T>> {
  Preview<Whole, T> get value => composeWithGetter(Getter((v) => v.value));
}

extension IdentityOpticsFoldSetExtension<Whole, T> on FoldSet<Whole, Identity<T>> {
  FoldSet<Whole, T> get value => composeWithGetter(Getter((v) => v.value));
}

extension IdentityOpticsMutatorExtension<Whole, T> on Mutator<Whole, Identity<T>> {
  Mutator<Whole, T> get value => compose(Mutator.iso(Getter((whole) {
        return whole.value;
      }), Getter((part) {
        return Identity(part);
      })));
}
