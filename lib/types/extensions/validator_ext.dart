// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/validator.dart';

extension ValidatorOpticExtension<S, A, B> on Optic<S, Validator<A, B>> {
  Optic<S, B> value() {
    return then(Optic.validator<A, B, B>());
  }

  Optic<S, IList<A>> errors() {
    return then(Optic.fromRun((update) {
      return (whole) {
        return whole.match((errors) {
          return Validator.errors(update(errors));
        }, (value) {
          return Validator.of(value);
        });
      };
    }));
  }
}
