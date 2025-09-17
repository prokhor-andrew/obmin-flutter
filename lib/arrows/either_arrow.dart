// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/either.dart';
import 'package:obmin/types/func.dart';

final class EitherArrow<E, Whole, Part> {
  final Func<Whole, Either<E, Part>> run;

  const EitherArrow(this.run);

  static EitherArrow<E, A, A> id<E, A>() {
    return EitherArrow(Either.right);
  }

  EitherArrow<E, Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return EitherArrow((whole) {
      return run(whole).rmap(f);
    });
  }

  EitherArrow<E, Whole, Sub> compose<Sub>(EitherArrow<E, Part, Sub> other) {
    return EitherArrow((whole) {
      return run(whole).bind(other.run);
    });
  }

  EitherArrow<E, Whole, (Part, Part2)> zipWith<Part2>(EitherArrow<E, Whole, Part2> other) {
    return EitherArrow((whole) {
      return run(whole).zipWith(other.run(whole));
    });
  }
}
