// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/validator.dart';

final class ValidatorArrow<E, Whole, Part> {
  final Func<Whole, Validator<E, Part>> run;

  const ValidatorArrow._(this.run);

  static ValidatorArrow<E, Whole, Part> fromRun<E, Whole, Part>(Func<Whole, Validator<E, Part>> run) {
    return ValidatorArrow._(run);
  }

  static ValidatorArrow<E, Whole, ()> unit<E, Whole>() {
    return ValidatorArrow.fromRun(constfunc(Validator.of(())));
  }

  static ValidatorArrow<E, Whole, Never> zero<E, Whole>() {
    return ValidatorArrow.fromRun(constfunc(Validator.errors(const IList.empty())));
  }

  ValidatorArrow<E, Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return ValidatorArrow.fromRun((whole) {
      return run(whole).rmap(f);
    });
  }

  ValidatorArrow<E2, Whole, Part> lmap<E2>(Func<E, E2> f) {
    return ValidatorArrow.fromRun((whole) {
      return run(whole).lmap(f);
    });
  }

  ValidatorArrow<E, Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return ValidatorArrow.fromRun((whole2) {
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
    return ValidatorArrow.fromRun(Validator.of);
  }

  ValidatorArrow<E, Whole, (Part, Part2)> zip<Part2>(ValidatorArrow<E, Whole, Part2> other) {
    return ValidatorArrow.fromRun((whole) {
      return run(whole).zipWith(other.run(whole));
    });
  }

  ValidatorArrow<E, Whole, Either<Part, Part2>> altLeftBiased<Part2>(ValidatorArrow<E, Whole, Part2> other) {
    return ValidatorArrow.fromRun((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return part.altLeftBiased(part2);
    });
  }

  ValidatorArrow<E, Whole, Either<Part, Part2>> altConcat<Part2>(ValidatorArrow<E, Whole, Part2> other) {
    return ValidatorArrow.fromRun((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return part.altConcat(part2);
    });
  }

  static ValidatorArrow<E, Whole, IList<Part>> zipAll<E, Whole, Part>(IList<ValidatorArrow<E, Whole, Part>> list) {
    return list.fold(ValidatorArrow.id(), (current, element) {
      final listInOption = element.rmap((value) => [value].lock);
      return current.zip(listInOption).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static ValidatorArrow<E, Whole, (int, Part)> altAllConcat<E, Whole, Part>(IList<ValidatorArrow<E, Whole, Part>> list) {
    return list.indexed.fold(ValidatorArrow.id(), (current, element) {
      final (index, option) = element;
      final indexedOption = option.rmap((value) => (index, value));
      return current.altConcat(indexedOption).rmap((either) {
        return either.value();
      });
    });
  }

  static ValidatorArrow<E, Whole, (int, Part)> altAllLeftBiased<E, Whole, Part>(IList<ValidatorArrow<E, Whole, Part>> list) {
    return list.indexed.fold(ValidatorArrow.id(), (current, element) {
      final (index, option) = element;
      final indexedOption = option.rmap((value) => (index, value));
      return current.altLeftBiased(indexedOption).rmap((either) {
        return either.value();
      });
    });
  }
}
