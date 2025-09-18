// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/writer.dart';

final class WriterArrow<E, Whole, Part> {
  final Func<Whole, Writer<E, Part>> run;

  const WriterArrow(this.run);

  static WriterArrow<E, Whole, ()> unit<E, Whole>() {
    return WriterArrow(constfunc(Writer(const IList.empty(), ())));
  }

  WriterArrow<E, Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return WriterArrow((whole) {
      return run(whole).rmap(f);
    });
  }

  WriterArrow<E2, Whole, Part> lmap<E2>(Func<E, E2> f) {
    return WriterArrow((whole) {
      return run(whole).lmap(f);
    });
  }

  WriterArrow<E, Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return WriterArrow((whole2) {
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
    return WriterArrow(Writer.of);
  }

  WriterArrow<E, Whole, Sub> then<Sub>(WriterArrow<E, Part, Sub> other) {
    return WriterArrow((whole) {
      return run(whole).bind(other.run);
    });
  }

  WriterArrow<E, Whole2, Part> after<Whole2>(WriterArrow<E, Whole2, Whole> other) {
    return other.then(this);
  }

  WriterArrow<E, Whole, (Part, Part2)> zipWith<Part2>(WriterArrow<E, Whole, Part2> other) {
    return WriterArrow((whole) {
      return run(whole).zipWith(other.run(whole));
    });
  }

  WriterArrow<E, Whole, Either<Part, Part2>> altWith<Part2>(WriterArrow<E, Whole, Part2> other) {
    return rmap(Either.left);
  }
}
