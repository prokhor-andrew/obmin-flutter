// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/func.dart' show Func;
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/list.dart';

extension IListOpticExtension<S, A> on Optic<S, IList<A>> {
  Optic<S, A> each() {
    return then<A>(Optic.list<A>());
  }

  Optic<S, A> at(int index) {
    return then<A>(Optic.fromRun<IList<A>, A>((update) {
      return (whole) {
        if (index < 0 || index >= whole.length) {
          return whole;
        } else {
          final element = whole[index];
          final updated = update(element);
          return whole.replace(index, updated);
        }
      };
    }));
  }

  Optic<S, A> where(Func<A, bool> predicate) {
    return then<A>(Optic.fromRun<IList<A>, A>((update) {
      return (whole) {
        return whole.where(predicate).toIList().rmap(update);
      };
    }));
  }
}

extension IListPathArrowExtension<Whole, A> on PathArrow<Whole, IList<A>> {
  PathArrow<Whole, A> each() {
    return then<A>(PathArrow.list<A>());
  }

  PathArrow<Whole, A> at(int index) {
    return then<A>(PathArrow.fromRun<IList<A>, A>((tuple) {
      final (list) = tuple;
      if (index < 0 || index >= list.length) {
        return IMap<IList<String>, A>.empty();
      }

      return {
        ["$index"].lock: (list[index])
      }.lock;
    }));
  }

  PathArrow<Whole, A> where(Func<A, bool> predicate) {
    return rmap((list) => list.where(predicate).toIList()).then<A>(PathArrow.list<A>());
  }
}
