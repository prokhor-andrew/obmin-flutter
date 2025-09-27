// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/flist.dart';

extension IListOpticExtension<S, A> on Optic<S, IList<A>> {
  Optic<S, A> each() {
    return then(Optic.list<A>());
  }

  Optic<S, A> at(int index) {
    return then(Optic.fromRun((update) {
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
}

extension IListPathArrowExtension<State, Whole, A> on PathArrow<State, Whole, IList<A>> {
  PathArrow<State, Whole, A> each() {
    return then(PathArrow.list<State, A>());
  }

  PathArrow<State, Whole, A> at(int index) {
    return then(PathArrow.fromRun((tuple) {
      final (state, list) = tuple;
      if (index < 0 || index >= list.length) {
        return const IMap.empty();
      }

      return {FList.of("$index"): (state, list[index])}.lock;
    }));
  }
}
