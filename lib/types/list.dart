// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'dart:math';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/either.dart';

import 'func.dart';

extension IListExtensions<A> on IList<A> {
  IList<A2> rmap<A2>(Func<A, A2> f) {
    return map(f).toIList();
  }

  IList<(A, A2)> zipCrossJoin<A2>(IList<A2> other) {
    IList<(A, A2)> result = const IList.empty();

    for (final a in this) {
      for (final a2 in other) {
        result = result.add((a, a2));
      }
    }

    return result;
  }

  IList<(A, A2)> zipPointIndex<A2>(IList<A2> other) {
    IList<(A, A2)> result = const IList.empty();

    final maxLength = min(length, other.length);

    for (int i = 0; i < maxLength; i++) {
      final item1 = this[i];
      final item2 = other[i];

      result = result.add((item1, item2));
    }

    return result;
  }

  IList<A2> bind<A2>(Func<A, IList<A2>> f) {
    return expand(f).toIList();
  }

  IList<Either<A, A2>> altConcat<A2>(IList<A2> other) {
    return rmap(Either.left<A, A2>).addAll(other.rmap(Either.right<A, A2>));
  }

  IList<Either<A, A2>> altLeftBiased<A2>(IList<A2> other) {
    if (isNotEmpty) {
      return rmap(Either.left);
    } else {
      return other.rmap(Either.right);
    }
  }
}

extension ListMonadExtension<T> on IList<IList<T>> {
  IList<T> joined() {
    return bind(idfunc);
  }
}
