// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_list.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/optics/transformers/bi_preview.dart';
import 'package:obmin/optics/transformers/iso.dart';
import 'package:obmin/optics/transformers/prism.dart';
import 'package:obmin/optics/transformers/reflector.dart';
import 'package:obmin/types/optional.dart';

extension OptionalOpticsEqvExtension<T> on Eqv<Optional<T>> {
  Preview<Optional<T>, T> get previewed => Preview((whole) => whole);
}

extension OptionalOpticsGetterExtension<Whole, T> on Getter<Whole, Optional<T>> {
  Preview<Whole, T> get previewed => composeWithPreview(Preview((whole) => whole));
}

extension OptionalOpticsPreviewExtension<Whole, T> on Preview<Whole, Optional<T>> {
  Preview<Whole, T> get previewed => compose(Preview((whole) => whole));
}

extension OptionalOpticsFoldListExtension<Whole, T> on FoldList<Whole, Optional<T>> {
  FoldList<Whole, T> get previewed => composeWithPreview(Preview((whole) => whole));
}

extension OptionalOpticsMutatorExtension<Whole, T> on Mutator<Whole, Optional<T>> {
  Mutator<Whole, T> get previewed => composeWithPrism(
        Prism(
          Preview((whole) => whole),
          Getter(Optional.some),
        ),
      );
}

extension OptionalOpticsIsoExtension<Whole, T> on Iso<Whole, Optional<T>> {
  Prism<Whole, T> get previewed => composeWithPrism(
        Prism(
          Preview((whole) => whole),
          Getter(Optional.some),
        ),
      );
}

extension OptionalOpticsPrismExtension<Whole, T> on Prism<Whole, Optional<T>> {
  Prism<Whole, T> get previewed => compose(
        Prism(
          Preview((whole) => whole),
          Getter(Optional.some),
        ),
      );
}

extension OptionalOpticsReflectorExtension<Whole, T> on Reflector<Whole, Optional<T>> {
  BiPreview<Whole, T> get previewed => composeWithPrism(
        Prism(
          Preview((whole) => whole),
          Getter(Optional.some),
        ),
      );
}

extension OptionalOpticsBiPreviewExtension<Whole, T> on BiPreview<Whole, Optional<T>> {
  BiPreview<Whole, T> get previewed => composeWithPrism(
        Prism(
          Preview((whole) => whole),
          Getter(Optional.some),
        ),
      );
}
