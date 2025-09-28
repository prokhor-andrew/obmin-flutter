// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/optics/optic.dart';

extension IMapOpticExtension<Key, S, A> on Optic<S, IMap<Key, A>> {
  Optic<S, A> each() {
    return then(Optic.map<Key, A>());
  }

  Optic<S, A> at(Key key) {
    return then(Optic.fromRun((update) {
      return (whole) {
        if (!whole.containsKey(key)) {
          return whole;
        }
        final element = whole.get(key) as A;
        final updated = update(element);
        return whole.add(key, updated);
      };
    }));
  }
}

extension IListPathArrowExtension<Key, State, Whole, A> on PathArrow<State, Whole, IMap<Key, A>> {
  PathArrow<State, Whole, A> each() {
    return then(PathArrow.map<Key, State, A>());
  }

  PathArrow<State, Whole, A> at(Key key) {
    return then(PathArrow.fromRun((tuple) {
      final (state, map) = tuple;
      if (!map.containsKey(key)) {
        return const IMap.empty();
      }

      final element = map.get(key) as A;

      return {
        ["${key.toString()}"].lock: (state, element)
      }.lock;
    }));
  }
}
