// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/list.dart';

final class FList<A> {
  final A _head;
  final IList<A> _tail;

  const FList(this._head, [this._tail = const IList.empty()]);

  static FList<()> unit() => const FList(());

  static FList<A> of<A>(A value) => unit().rmap(constfunc(value));

  A head() => _head;

  IList<A> tail() => _tail;

  FList<A> add(A value) {
    return FList(_head, _tail.add(value));
  }

  FList<A> addAll(FList<A> list) {
    return FList(_head, _tail.add(list._head).addAll(list._tail));
  }

  FList<A2> rmap<A2>(Func<A, A2> f) {
    return FList(f(_head), _tail.rmap(f));
  }

  FList<(A, A2)> zip<A2>(FList<A2> other) {
    return bind((a) => other.rmap((a2) => (a, a2)));
  }

  FList<A2> bind<A2>(Func<A, FList<A2>> f) {
    final part1 = f(_head);
    final part2 = _tail.bind((val) {
      final res = f(val);
      return [res._head].lock.addAll(res._tail);
    });
    return FList(part1._head, part1._tail.addAll(part2));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! FList<A>) {
      return false;
    }

    return _head == other._head && _tail == other._tail;
  }
}

extension FListExtension<A> on FList<FList<A>> {
  FList<A> joined() {
    return bind(idfunc);
  }
}
