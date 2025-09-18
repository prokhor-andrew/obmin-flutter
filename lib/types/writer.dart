// Copyright (A) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/func.dart';

import 'either.dart';

final class Writer<A, B> {
  final IList<A> list;
  final B value;

  const Writer(this.list, this.value);

  const Writer.of(this.value) : list = const IList.empty();

  Writer<A, T2> rmap<T2>(Func<B, T2> f) {
    return Writer(list, f(value));
  }

  Writer<C2, B> lmap<C2>(Func<A, C2> f) {
    return Writer(list.map(f).toIList(), value);
  }

  Writer<A2, B2> bimap<A2, B2>(Func<A, A2> lf, Func<B, B2> rf) {
    return lmap(lf).rmap(rf);
  }

  Writer<A, T2> bind<T2>(Func<B, Writer<A, T2>> f) {
    final newWriter = f(value);
    return Writer(list.addAll(newWriter.list), newWriter.value);
  }

  Writer<A, (B, T2)> zipWith<T2>(Writer<A, T2> other) {
    final newList = list.addAll(other.list);
    return Writer(newList, (value, other.value));
  }

  Writer<A, Either<B, T2>> altWith<T2>(Writer<A, T2> other) {
    return rmap(Either.left);
  }

  (IList<A>, B) asTuple() {
    return (list, value);
  }
}

extension WriterMonadExtension<E, T> on Writer<E, Writer<E, T>> {
  Writer<E, T> joined() {
    return bind(idfunc);
  }
}
