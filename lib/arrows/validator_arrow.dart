// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/either.dart';
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

  ValidatorArrow<E2, Whole, Part2> bimap<E2, Part2>(Func<E, E2> lf, Func<Part, Part2> rf) {
    return lmap(lf).rmap(rf);
  }

  ValidatorArrow<E, Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap(lf).rmap(rf);
  }

  static ValidatorArrow<E, A, A> id<E, A>() {
    return ValidatorArrow(Validator.of);
  }

  ValidatorArrow<E, Whole, (Part, Part2)> zipWith<Part2>(ValidatorArrow<E, Whole, Part2> other) {
    return ValidatorArrow((whole) {
      return run(whole).zipWith(other.run(whole));
    });
  }

  ValidatorArrow<E, Whole, Either<Part, Part2>> altWithLeftBiased<Part2>(ValidatorArrow<E, Whole, Part2> other) {
    return ValidatorArrow((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return part.altWithLeftBiased(part2);
    });
  }

  ValidatorArrow<E, Whole, Either<Part, Part2>> altWithConcat<Part2>(ValidatorArrow<E, Whole, Part2> other) {
    return ValidatorArrow((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return part.altWithConcat(part2);
    });
  }
}
