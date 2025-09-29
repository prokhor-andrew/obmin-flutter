// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/writer.dart';

final class WriterArrow<E, Whole, Part> {
  final Func<Whole, Writer<E, Part>> run;

  const WriterArrow._(this.run);

  static WriterArrow<E, Whole, Part> fromRun<E, Whole, Part>(Func<Whole, Writer<E, Part>> run) {
    return WriterArrow._(run);
  }

  static WriterArrow<E, Whole, Part> fromFunc<E, Whole, Part>(Func<Whole, Part> f) {
    return WriterArrow.fromRun<E, Whole, Part>((whole) {
      final part = f(whole);
      return WriterArrow.id<E, Part>().run(part);
    });
  }

  static WriterArrow<E, Whole, ()> unit<E, Whole>() {
    return WriterArrow.fromRun<E, Whole, ()>(constfunc<Whole, Writer<E, ()>>(Writer(IList<E>.empty(), ())));
  }

  WriterArrow<E, Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return WriterArrow.fromRun<E, Whole, Part2>((whole) {
      return run(whole).rmap<Part2>(f);
    });
  }

  WriterArrow<E2, Whole, Part> lmap<E2>(Func<E, E2> f) {
    return WriterArrow.fromRun<E2, Whole, Part>((whole) {
      return run(whole).lmap<E2>(f);
    });
  }

  WriterArrow<E, Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return WriterArrow.fromRun<E, Whole2, Part>((whole2) {
      return run(f(whole2));
    });
  }

  WriterArrow<E2, Whole, Part2> bimap<E2, Part2>(Func<E, E2> lf, Func<Part, Part2> rf) {
    return lmap<E2>(lf).rmap<Part2>(rf);
  }

  WriterArrow<E, Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap<Whole2>(lf).rmap<Part2>(rf);
  }

  static WriterArrow<E, A, A> id<E, A>() {
    return WriterArrow.fromRun<E, A, A>(Writer.of<E, A>);
  }

  WriterArrow<E, Whole, Sub> then<Sub>(WriterArrow<E, Part, Sub> other) {
    return WriterArrow.fromRun<E, Whole, Sub>((whole) {
      return run(whole).bind<Sub>(other.run);
    });
  }

  WriterArrow<E, Whole2, Part> after<Whole2>(WriterArrow<E, Whole2, Whole> other) {
    return other.then<Part>(this);
  }

  WriterArrow<E, Whole, (Part, Part2)> zip<Part2>(WriterArrow<E, Whole, Part2> other) {
    return WriterArrow.fromRun<E, Whole, (Part, Part2)>((whole) {
      return run(whole).zip<Part2>(other.run(whole));
    });
  }

  static WriterArrow<E, Whole, IList<Part>> zipAll<E, Whole, Part>(IList<WriterArrow<E, Whole, Part>> list) {
    return list.fold<WriterArrow<E, Whole, IList<Part>>>(WriterArrow.fromRun<E, Whole, IList<Part>>((_) => Writer.of<E, IList<Part>>(IList<Part>.empty())), (current, element) {
      final arrow = element.rmap<IList<Part>>((value) => [value].lock);
      return current.zip<IList<Part>>(arrow).rmap<IList<Part>>((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  WriterArrow<E, (A, Whole), (A, Part)> strong<A>() {
    return WriterArrow.fromRun<E, (A, Whole), (A, Part)>((tuple) {
      final (a, whole) = tuple;
      final functor = run(whole);
      return functor.rmap<(A, Part)>((part) => (a, part));
    });
  }

  WriterArrow<E, Either<A, Whole>, Either<A, Part>> choice<A>() {
    return WriterArrow.fromRun<E, Either<A, Whole>, Either<A, Part>>((either) {
      return either.match<Writer<E, Either<A, Part>>>((a) {
        return WriterArrow.id<E, Either<A, Part>>().run(Either.left<A, Part>(a));
      }, (whole) {
        final functor = run(whole);
        return functor.rmap<Either<A, Part>>((part) => Either.right<A, Part>(part));
      });
    });
  }
}
