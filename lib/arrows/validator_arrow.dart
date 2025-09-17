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

  ValidatorArrow<E2, Whole, Part> lmap<E2>(Func<E, E2> f) {
    return ValidatorArrow((whole) {
      return run(whole).lmap(f);
    });
  }

  ValidatorArrow<E, Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return ValidatorArrow((whole2) {
      return run(f(whole2));
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
