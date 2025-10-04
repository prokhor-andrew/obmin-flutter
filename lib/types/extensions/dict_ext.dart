// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/arrows/option_arrow.dart';
import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/option.dart';

extension IMapOpticExtension<Key, S, A> on Optic<S, IMap<Key, A>> {
  Optic<S, A> each() {
    return then<A>(Optic.dict<Key, A>());
  }

  Optic<S, A> at(Key key) {
    return then<A>(Optic.fromRun<IMap<Key, A>, A>((update) {
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

extension IMapPathArrowExtension<Key, Whole, A> on PathArrow<Whole, IMap<Key, A>> {
  PathArrow<Whole, A> each() {
    return then<A>(PathArrow.dict<Key, A>());
  }

  PathArrow<Whole, A> at(Key key) {
    return then<A>(PathArrow.fromRun<IMap<Key, A>, A>((tuple) {
      final (map) = tuple;
      if (!map.containsKey(key)) {
        return IMap<IList<String>, A>.empty();
      }

      final element = map.get(key) as A;

      return {
        ["${key.toString()}"].lock: element
      }.lock;
    }));
  }
}

extension IMapOptionArrowExtension<Key, Whole, A> on OptionArrow<Whole, IMap<Key, A>> {
  OptionArrow<Whole, A> at(Key key) {
    return then<A>(OptionArrow.fromRun<IMap<Key, A>, A>((map) {
      if (!map.containsKey(key)) {
        return Option.none<A>();
      }

      final element = map.get(key) as A;

      return Option.some(element);
    }));
  }
}