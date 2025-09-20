// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/func.dart';

final class EitherArrow<E, Whole, Part> {
  final Func<Whole, Either<E, Part>> run;

  const EitherArrow(this.run);

  static EitherArrow<E, Whole, ()> unit<E, Whole>() {
    return EitherArrow(constfunc(Either.right(())));
  }

  static EitherArrow<E, A, A> id<E, A>() {
    return EitherArrow(Either.right);
  }

  EitherArrow<E, Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return EitherArrow((whole) {
      return run(whole).rmap(f);
    });
  }

  EitherArrow<E2, Whole, Part> lmap<E2>(Func<E, E2> f) {
    return EitherArrow((whole) {
      return run(whole).lmap(f);
    });
  }

  EitherArrow<E2, Whole, Part2> bimap<E2, Part2>(Func<E, E2> lf, Func<Part, Part2> rf) {
    return lmap(lf).rmap(rf);
  }

  EitherArrow<E, Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap(lf).rmap(rf);
  }

  EitherArrow<E, Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return EitherArrow((whole2) {
      return run(f(whole2));
    });
  }

  EitherArrow<E, Whole, Sub> then<Sub>(EitherArrow<E, Part, Sub> other) {
    return EitherArrow((whole) {
      return run(whole).bind(other.run);
    });
  }

  EitherArrow<E, Whole2, Part> after<Whole2>(EitherArrow<E, Whole2, Whole> other) {
    return other.then(this);
  }

  EitherArrow<E, Whole, (Part, Part2)> zip<Part2>(EitherArrow<E, Whole, Part2> other) {
    return EitherArrow((whole) {
      return run(whole).zip(other.run(whole));
    });
  }

  EitherArrow<E2, Whole, Part> recover<E2>(EitherArrow<E2, E, Part> other) {
    return EitherArrow((whole) {
      return run(whole).rescue(other.run);
    });
  }

  EitherArrow<E, Whole, Part> orElseArrow(EitherArrow<E, Whole, Part> fallback) {
    return orElseFunc(constfunc(fallback));
  }

  EitherArrow<E2, Whole, Part> orElseFunc<E2>(Func<E, EitherArrow<E2, Whole, Part>> f) {
    return EitherArrow((whole) {
      return run(whole).match(
        (e) => f(e).run(whole),
        Either.right,
      );
    });
  }

  static EitherArrow<E, Whole, IList<Part>> zipAll<E, Whole, Part>(IList<EitherArrow<E, Whole, Part>> list) {
    return list.fold(EitherArrow.id(), (current, element) {
      final listInOption = element.rmap((value) => [value].lock);
      return current.zip(listInOption).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }
}
