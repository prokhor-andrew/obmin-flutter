// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'dart:math';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'func.dart';

extension IListExtensions<A> on IList<A> {
  IList<A2> rmap<A2>(Func<A, A2> f) {
    return map(f).toIList();
  }

  IList<(A, A2)> crossJoinZipWith<A2>(IList<A2> other) {
    IList<(A, A2)> result = const IList.empty();

    for (final a in this) {
      for (final a2 in other) {
        result = result.add((a, a2));
      }
    }

    return result;
  }

  IList<(A, A2)> pointIndexZipWith<A2>(IList<A2> other) {
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
}
