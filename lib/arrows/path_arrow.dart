// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/func.dart';

final class PathArrow<State, Key, Whole, Part> {
  final Func<(State, Whole), IMap<IList<Key>, (State, Part)>> run;

  const PathArrow._(this.run);

  static PathArrow<State, Key, Whole, Part> fromRun<State, Key, Whole, Part>(Func<(State, Whole), IMap<IList<Key>, (State, Part)>> run) {
    return PathArrow._(run);
  }

  static PathArrow<State, Key, Whole, ()> unit<State, Key, Whole>() {
    return PathArrow.fromRun((tuple) {
      return {IList<Key>.empty(): (tuple.$1, ())}.lock;
    });
  }

  static PathArrow<State, Key, Whole, Never> zero<State, Key, Whole>() {
    return PathArrow.fromRun(constfunc(const IMap.empty()));
  }

  static PathArrow<State, Key, A, A> id<State, Key, A>() {
    return PathArrow.fromRun((tuple) => {IList<Key>.empty(): tuple}.lock);
  }

  PathArrow<State, Key, Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return PathArrow.fromRun((tuple) {
      final map = run(tuple);
      return map.map((key, value) => MapEntry(key, (value.$1, f(value.$2))));
    });
  }

  PathArrow<State, Key, Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return PathArrow.fromRun((tuple) {
      return run((tuple.$1, f(tuple.$2)));
    });
  }

  PathArrow<State2, Key, Whole, Part> imap<State2>(Func<State2, State> lf, Func<State, State2> rf) {
    return PathArrow.fromRun((tuple) {
      final map = run((lf(tuple.$1), tuple.$2));
      return map.map((key, value) => MapEntry(key, (rf(value.$1), value.$2)));
    });
  }

  PathArrow<State, Key, Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap(lf).rmap(rf);
  }

  PathArrow<State, Key, Whole, Sub> then<Sub>(PathArrow<State, Key, Part, Sub> other) {
    return PathArrow.fromRun((tuple) {
      IMap<IList<Key>, (State, Sub)> result = const IMap.empty();

      for (final entry in run(tuple).entries) {
        final innerMap = other.run(entry.value);
        final transformedMap = innerMap.map((key, value) => MapEntry(entry.key.addAll(key), value));

        result = result.addAll(transformedMap);
      }

      return result;
    });
  }

  PathArrow<State, Key, Whole2, Part> after<Whole2>(PathArrow<State, Key, Whole2, Whole> other) {
    return other.then(this);
  }

  PathArrow<State, Key, Whole, (Part, Part2)> zip<Part2>(PathArrow<State, Key, Whole, Part2> other) {
    return PathArrow.fromRun((tuple) {
      IMap<IList<Key>, (State, (Part, Part2))> out = const IMap.empty();
      for (final w1 in run(tuple).entries) {
        final (log1, (s1, p1)) = (w1.key, w1.value);
        for (final w2 in other.run((s1, tuple.$2)).entries) {
          final (log2, (s2, p2)) = (w2.key, w2.value);
          out = out.add(log1.addAll(log2), (s2, (p1, p2)));
        }
      }
      return out;
    });
  }

  PathArrow<State, Key, Whole, Either<Part, Part2>> altConcat<Part2>(PathArrow<State, Key, Whole, Part2> other) {
    return PathArrow.fromRun((tuple) {
      final arr1 = rmap(Either.left<Part, Part2>);
      final arr2 = other.rmap(Either.right<Part, Part2>);

      return arr1.run(tuple).addAll(arr2.run(tuple));
    });
  }

  PathArrow<State, Key, Whole, Either<Part, Part2>> altLeftBiased<Part2>(PathArrow<State, Key, Whole, Part2> other) {
    return PathArrow.fromRun((tuple) {
      return rmap(Either.left<Part, Part2>).run(tuple);
    });
  }

  static PathArrow<E, Key, Whole, IList<Part>> zipAll<E, Key, Whole, Part>(IList<PathArrow<E, Key, Whole, Part>> list) {
    return list.fold(PathArrow.id(), (current, element) {
      final listInOption = element.rmap((value) => [value].lock);
      return current.zip(listInOption).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static PathArrow<E, Key, Whole, (int, Part)> altAllLeftBiased<E, Key, Whole, Part>(IList<PathArrow<E, Key, Whole, Part>> list) {
    return list.indexed.fold(PathArrow.id(), (current, element) {
      final (index, option) = element;
      final indexedOption = option.rmap((value) => (index, value));
      return current.altLeftBiased(indexedOption).rmap((either) {
        return either.value();
      });
    });
  }

  static PathArrow<E, Key, Whole, (int, Part)> altAllConcat<E, Key, Whole, Part>(IList<PathArrow<E, Key, Whole, Part>> list) {
    return list.indexed.fold(PathArrow.id(), (current, element) {
      final (index, option) = element;
      final indexedOption = option.rmap((value) => (index, value));
      return current.altConcat(indexedOption).rmap((either) {
        return either.value();
      });
    });
  }
}
