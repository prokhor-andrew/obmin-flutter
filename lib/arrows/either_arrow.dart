// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/either.dart';

final class EitherArrow<E, Whole, Part> {
  final Func<Whole, Either<E, Part>> run;

  const EitherArrow._(this.run);

  static EitherArrow<E, Whole, Part> fromRun<E, Whole, Part>(Func<Whole, Either<E, Part>> run) {
    return EitherArrow._(run);
  }

  static EitherArrow<E, Whole, Part> fromFunc<E, Whole, Part>(Func<Whole, Part> f) {
    return EitherArrow.fromRun<E, Whole, Part>((whole) {
      final part = f(whole);
      return EitherArrow.id<E, Part>().run(part);
    });
  }

  static EitherArrow<E, Whole, ()> unit<E, Whole>() {
    return EitherArrow.fromRun<E, Whole, ()>(constfunc(Either.right<E, ()>(())));
  }

  static EitherArrow<E, A, A> id<E, A>() {
    return EitherArrow.fromRun<E, A, A>(Either.right<E, A>);
  }

  EitherArrow<E, Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return EitherArrow.fromRun<E, Whole, Part2>((whole) {
      return run(whole).rmap<Part2>(f);
    });
  }

  EitherArrow<E2, Whole, Part> lmap<E2>(Func<E, E2> f) {
    return EitherArrow.fromRun<E2, Whole, Part>((whole) {
      return run(whole).lmap<E2>(f);
    });
  }

  EitherArrow<E2, Whole, Part2> bimap<E2, Part2>(Func<E, E2> lf, Func<Part, Part2> rf) {
    return lmap<E2>(lf).rmap<Part2>(rf);
  }

  EitherArrow<E, Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap<Whole2>(lf).rmap<Part2>(rf);
  }

  EitherArrow<E, Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return EitherArrow.fromRun<E, Whole2, Part>((whole2) {
      return run(f(whole2));
    });
  }

  EitherArrow<E, Whole, Sub> then<Sub>(EitherArrow<E, Part, Sub> other) {
    return EitherArrow.fromRun<E, Whole, Sub>((whole) {
      return run(whole).bind<Sub>(other.run);
    });
  }

  EitherArrow<E, Whole2, Part> after<Whole2>(EitherArrow<E, Whole2, Whole> other) {
    return other.then<Part>(this);
  }

  EitherArrow<E, Whole, (Part, Part2)> zip<Part2>(EitherArrow<E, Whole, Part2> other) {
    return EitherArrow.fromRun<E, Whole, (Part, Part2)>((whole) {
      return run(whole).zip<Part2>(other.run(whole));
    });
  }

  EitherArrow<E2, Whole, Part> recover<E2>(EitherArrow<E2, E, Part> other) {
    return EitherArrow.fromRun<E2, Whole, Part>((whole) {
      return run(whole).rescue<E2>(other.run);
    });
  }

  EitherArrow<E, Whole, Part> orElseArrow(EitherArrow<E, Whole, Part> fallback) {
    return orElseFunc<E>(constfunc(fallback));
  }

  EitherArrow<E2, Whole, Part> orElseFunc<E2>(Func<E, EitherArrow<E2, Whole, Part>> f) {
    return EitherArrow.fromRun<E2, Whole, Part>((whole) {
      return run(whole).match<Either<E2, Part>>(
        (e) => f(e).run(whole),
        Either.right<E2, Part>,
      );
    });
  }

  static EitherArrow<E, Whole, IList<Part>> zipAll<E, Whole, Part>(IList<EitherArrow<E, Whole, Part>> list) {
    return list.fold<EitherArrow<E, Whole, IList<Part>>>(EitherArrow.fromRun<E, Whole, IList<Part>>((_) => Either.right<E, IList<Part>>(IList<Part>.empty())), (current, element) {
      final arrow = element.rmap<IList<Part>>((value) => [value].lock);
      return current.zip<IList<Part>>(arrow).rmap<IList<Part>>((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  EitherArrow<E, (A, Whole), (A, Part)> strong<A>() {
    return EitherArrow.fromRun<E, (A, Whole), (A, Part)>((tuple) {
      final (a, whole) = tuple;
      final functor = run(whole);
      return functor.rmap<(A, Part)>((part) => (a, part));
    });
  }

  EitherArrow<E, Either<A, Whole>, Either<A, Part>> choice<A>() {
    return EitherArrow.fromRun<E, Either<A, Whole>, Either<A, Part>>((either) {
      return either.match<Either<E, Either<A, Part>>>((a) {
        return id<E, Either<A, Part>>().run(Either.left<A, Part>(a));
      }, (whole) {
        final functor = run(whole);
        return functor.rmap<Either<A, Part>>((part) => Either.right<A, Part>(part));
      });
    });
  }
}
