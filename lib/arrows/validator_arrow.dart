// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/validator.dart';

final class ValidatorArrow<E, Whole, Part> {
  final Func<Whole, Validator<E, Part>> run;

  const ValidatorArrow._(this.run);

  static ValidatorArrow<E, Whole, Part> fromRun<E, Whole, Part>(Func<Whole, Validator<E, Part>> run) {
    return ValidatorArrow._(run);
  }

  static ValidatorArrow<E, Whole, Part> fromFunc<E, Whole, Part>(Func<Whole, Part> f) {
    return ValidatorArrow.fromRun<E, Whole, Part>((whole) {
      final part = f(whole);
      return ValidatorArrow.id<E, Part>().run(part);
    });
  }

  static ValidatorArrow<E, Whole, ()> unit<E, Whole>() {
    return ValidatorArrow.fromRun<E, Whole, ()>(constfunc<Whole, Validator<E, ()>>(Validator.of<E, ()>(())));
  }

  static ValidatorArrow<E, Whole, Never> zero<E, Whole>() {
    return ValidatorArrow.fromRun<E, Whole, Never>(constfunc<Whole, Validator<E, Never>>(Validator.errors<E, Never>(IList<E>.empty())));
  }

  ValidatorArrow<E, Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return ValidatorArrow.fromRun<E, Whole, Part2>((whole) {
      return run(whole).rmap<Part2>(f);
    });
  }

  ValidatorArrow<E2, Whole, Part> lmap<E2>(Func<E, E2> f) {
    return ValidatorArrow.fromRun<E2, Whole, Part>((whole) {
      return run(whole).lmap<E2>(f);
    });
  }

  ValidatorArrow<E, Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return ValidatorArrow.fromRun<E, Whole2, Part>((whole2) {
      return run(f(whole2));
    });
  }

  ValidatorArrow<E2, Whole, Part2> bimap<E2, Part2>(Func<E, E2> lf, Func<Part, Part2> rf) {
    return lmap<E2>(lf).rmap<Part2>(rf);
  }

  ValidatorArrow<E, Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap<Whole2>(lf).rmap<Part2>(rf);
  }

  static ValidatorArrow<E, A, A> id<E, A>() {
    return ValidatorArrow.fromRun<E, A, A>(Validator.of<E, A>);
  }

  ValidatorArrow<E, Whole, (Part, Part2)> zip<Part2>(ValidatorArrow<E, Whole, Part2> other) {
    return ValidatorArrow.fromRun<E, Whole, (Part, Part2)>((whole) {
      return run(whole).zip<Part2>(other.run(whole));
    });
  }

  ValidatorArrow<E, Whole, Either<Part, Part2>> altLeftBiased<Part2>(ValidatorArrow<E, Whole, Part2> other) {
    return ValidatorArrow.fromRun<E, Whole, Either<Part, Part2>>((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return part.altLeftBiased<Part2>(part2);
    });
  }

  ValidatorArrow<E, Whole, Either<Part, Part2>> altConcat<Part2>(ValidatorArrow<E, Whole, Part2> other) {
    return ValidatorArrow.fromRun<E, Whole, Either<Part, Part2>>((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return part.altConcat<Part2>(part2);
    });
  }

  static ValidatorArrow<E, Whole, IList<Part>> zipAll<E, Whole, Part>(IList<ValidatorArrow<E, Whole, Part>> list) {
    return list.fold<ValidatorArrow<E, Whole, IList<Part>>>(ValidatorArrow.fromRun<E, Whole, IList<Part>>((_) => Validator.of<E, IList<Part>>(IList<Part>.empty())), (current, element) {
      final arrow = element.rmap<IList<Part>>((value) => [value].lock);
      return current.zip<IList<Part>>(arrow).rmap<IList<Part>>((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static ValidatorArrow<E, Whole, (int, Part)> altAllConcatTagged<E, Whole, Part>(IList<ValidatorArrow<E, Whole, Part>> list) {
    return list.indexed.fold<ValidatorArrow<E, Whole, (int, Part)>>(ValidatorArrow.zero<E, Whole>(), (current, element) {
      final (index, option) = element;
      final indexedOption = option.rmap<(int, Part)>((value) => (index, value));
      return current.altConcat<(int, Part)>(indexedOption).rmap<(int, Part)>((either) {
        return either.value();
      });
    });
  }

  static ValidatorArrow<E, Whole, Part> altAllConcat<E, Whole, Part>(IList<ValidatorArrow<E, Whole, Part>> list) {
    return altAllConcatTagged(list).rmap((tuple) => tuple.$2);
  }

  static ValidatorArrow<E, Whole, (int, Part)> altAllLeftBiasedTagged<E, Whole, Part>(IList<ValidatorArrow<E, Whole, Part>> list) {
    return list.indexed.fold<ValidatorArrow<E, Whole, (int, Part)>>(ValidatorArrow.zero<E, Whole>(), (current, element) {
      final (index, option) = element;
      final indexedOption = option.rmap<(int, Part)>((value) => (index, value));
      return current.altLeftBiased<(int, Part)>(indexedOption).rmap<(int, Part)>((either) {
        return either.value();
      });
    });
  }

  static ValidatorArrow<E, Whole, Part> altAllLeftBiased<E, Whole, Part>(IList<ValidatorArrow<E, Whole, Part>> list) {
    return altAllLeftBiasedTagged(list).rmap((tuple) => tuple.$2);
  }

  ValidatorArrow<E, (A, Whole), (A, Part)> strong<A>() {
    return ValidatorArrow.fromRun<E, (A, Whole), (A, Part)>((tuple) {
      final (a, whole) = tuple;
      final functor = run(whole);
      return functor.rmap<(A, Part)>((part) => (a, part));
    });
  }

  ValidatorArrow<E, Either<A, Whole>, Either<A, Part>> choice<A>() {
    return ValidatorArrow.fromRun<E, Either<A, Whole>, Either<A, Part>>((either) {
      return either.match<Validator<E, Either<A, Part>>>((a) {
        return ValidatorArrow.id<E, Either<A, Part>>().run(Either.left<A, Part>(a));
      }, (whole) {
        final functor = run(whole);
        return functor.rmap<Either<A, Part>>((part) => Either.right<A, Part>(part));
      });
    });
  }
}
