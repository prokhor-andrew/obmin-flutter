// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/func.dart';
import 'package:obmin/types/validator.dart';

final class ValidatorArrow<E, Whole, Part> {
  final Func<Whole, Validator<E, Part>> run;

  const ValidatorArrow(this.run);

  ValidatorArrow<E, Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return ValidatorArrow((whole) {
      return run(whole).rmap(f);
    });
  }

  static ValidatorArrow<E, A, A> id<E, A>() {
    return ValidatorArrow(Validator.of);
  }

  ValidatorArrow<E, Whole, (Part, Part2)> zipWith<Part2>(ValidatorArrow<E, Whole, Part2> other) {
    return ValidatorArrow((whole) {
      return run(whole).zipWith(other.run(whole));
    });
  }
}
