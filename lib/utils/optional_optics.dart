// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/fp/optional.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

extension OptionalOpticsEqvExtension<T> on Eqv<Optional<T>> {
  Preview<Optional<T>, T> get previewed => Preview((whole) => whole);
}

extension OptionalOpticsGetterExtension<Whole, T> on Getter<Whole, Optional<T>> {
  Preview<Whole, T> get previewed => composeWithPreview(Preview((whole) => whole));
}

extension OptionalOpticsPreviewExtension<Whole, T> on Preview<Whole, Optional<T>> {
  Preview<Whole, T> get previewed => compose(Preview((whole) => whole));
}

extension OptionalOpticsFoldSetExtension<Whole, T> on FoldSet<Whole, Optional<T>> {
  FoldSet<Whole, T> get previewed => composeWithPreview(Preview((whole) => whole));
}

extension OptionalOpticsMutatorExtension<Whole, T> on Mutator<Whole, Optional<T>> {
  Mutator<Whole, T> get previewed => compose(
        Mutator.prism(
          Preview((whole) => whole),
          Getter(Optional.some),
        ),
      );
}
