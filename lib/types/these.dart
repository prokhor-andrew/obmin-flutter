// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/either.dart';
import 'package:obmin/types/func.dart';

final class These<A, B> {
  final Either<Either<A, B>, (A, B)> _either;

  const These._(this._either);

  static These<A, B> left<A, B>(A value) => These._(Either.left(Either.left(value)));

  static These<A, B> right<A, B>(B value) => These._(Either.left(Either.right(value)));

  static These<A, B> both<A, B>(A value1, B value2) => These._(Either.right((value1, value2)));

  T match<T>(
    Func<A, T> ifLeft,
    Func<B, T> ifRight,
    BiFunc<A, B, T> ifBoth,
  ) {
    return _either.match((either) {
      return either.match(ifLeft, ifRight);
    }, (both) {
      final (a, b) = both;
      return ifBoth(a, b);
    });
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! These<A, B>) return false;

    return match(
      (a) => other.match(
        (a2) => a == a2,
        constfunc(false),
        (_, __) => false,
      ),
      (b) => other.match(
        constfunc(false),
        (b2) => b == b2,
        (_, __) => false,
      ),
      (a, b) => other.match(
        constfunc(false),
        constfunc(false),
        (a2, b2) => a == a2 && b == b2,
      ),
    );
  }

  @override
  int get hashCode => match(
        (a) => a.hashCode,
        (b) => b.hashCode,
        (a, b) => a.hashCode ^ b.hashCode,
      );

  These<B, A> swapped() {
    return match(These.right, These.left, (a, b) => These.both(b, a));
  }

  These<A, B2> map<B2>(Func<B, B2> f) {
    return match(
      These.left,
      (b) => These.right(f(b)),
      (a, b) => These.both(a, f(b)),
    );
  }

  These<A, B2> rmap<B2>(Func<B, B2> f) {
    return map(f);
  }

  These<A2, B> lmap<A2>(Func<A, A2> f) {
    return swapped().rmap(f).swapped();
  }

  These<A2, B2> bimap<A2, B2>(Func<A, A2> lf, Func<B, B2> rf) {
    return lmap(lf).rmap(rf);
  }
}
