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

  static WriterArrow<E, Whole, ()> unit<E, Whole>() {
    return WriterArrow.fromRun(constfunc(Writer(const IList.empty(), ())));
  }

  WriterArrow<E, Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return WriterArrow.fromRun((whole) {
      return run(whole).rmap(f);
    });
  }

  WriterArrow<E2, Whole, Part> lmap<E2>(Func<E, E2> f) {
    return WriterArrow.fromRun((whole) {
      return run(whole).lmap(f);
    });
  }

  WriterArrow<E, Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return WriterArrow.fromRun((whole2) {
      return run(f(whole2));
    });
  }

  WriterArrow<E2, Whole, Part2> bimap<E2, Part2>(Func<E, E2> lf, Func<Part, Part2> rf) {
    return lmap(lf).rmap(rf);
  }

  WriterArrow<E, Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap(lf).rmap(rf);
  }

  static WriterArrow<E, A, A> id<E, A>() {
    return WriterArrow.fromRun(Writer.of);
  }

  WriterArrow<E, Whole, Sub> then<Sub>(WriterArrow<E, Part, Sub> other) {
    return WriterArrow.fromRun((whole) {
      return run(whole).bind(other.run);
    });
  }

  WriterArrow<E, Whole2, Part> after<Whole2>(WriterArrow<E, Whole2, Whole> other) {
    return other.then(this);
  }

  WriterArrow<E, Whole, (Part, Part2)> zip<Part2>(WriterArrow<E, Whole, Part2> other) {
    return WriterArrow.fromRun((whole) {
      return run(whole).zip(other.run(whole));
    });
  }

  static WriterArrow<E, Whole, IList<Part>> zipAll<E, Whole, Part>(IList<WriterArrow<E, Whole, Part>> list) {
    return list.fold(WriterArrow.id(), (current, element) {
      final arrow = element.rmap((value) => [value].lock);
      return current.zip(arrow).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  WriterArrow<E, (A, Whole), (A, Part)> strong<A>() {
    return WriterArrow.fromRun((tuple) {
      final (a, whole) = tuple;
      final functor = run(whole);
      return functor.rmap((part) => (a, part));
    });
  }

  WriterArrow<E, Either<A, Whole>, Either<A, Part>> choice<A>() {
    return WriterArrow.fromRun((either) {
      return either.match((a) {
        return id<E, Either<A, Part>>().run(Either.left(a));
      }, (whole) {
        final functor = run(whole);
        return functor.rmap((part) => Either.right(part));
      });
    });
  }
}
