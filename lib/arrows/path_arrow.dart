// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/flist.dart';
import 'package:obmin/types/func.dart';

final class PathArrow<State, Whole, Part> {
  final Func<(State, Whole), IMap<FList<String>, (State, Part)>> run;

  const PathArrow._(this.run);

  static PathArrow<State, Whole, Part> fromRun<State, Whole, Part>(Func<(State, Whole), IMap<FList<String>, (State, Part)>> run) {
    return PathArrow._(run);
  }

  PathArrow<State, Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return PathArrow.fromRun((tuple) {
      final map = run(tuple);
      return map.map((key, value) => MapEntry(key, (value.$1, f(value.$2))));
    });
  }

  PathArrow<State, Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return PathArrow.fromRun((tuple) {
      return run((tuple.$1, f(tuple.$2)));
    });
  }

  PathArrow<State2, Whole, Part> imap<State2>(Func<State2, State> lf, Func<State, State2> rf) {
    return PathArrow.fromRun((tuple) {
      final map = run((lf(tuple.$1), tuple.$2));
      return map.map((key, value) => MapEntry(key, (rf(value.$1), value.$2)));
    });
  }

  PathArrow<State, Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap(lf).rmap(rf);
  }

  PathArrow<State, Whole, Sub> then<Sub>(PathArrow<State, Part, Sub> other) {
    return PathArrow.fromRun((tuple) {
      IMap<FList<String>, (State, Sub)> result = const IMap.empty();

      final outerMap = run(tuple);
      for (final entry in outerMap.entries) {
        final outerKey = entry.key;
        final outerValue = entry.value;

        final innerMap = other.run(outerValue);
        final transformedMap = innerMap.map((key, value) => MapEntry(outerKey.addAll(key), value));

        result = result.addAll(transformedMap);
      }

      return result;
    });
  }

  PathArrow<State, Whole2, Part> after<Whole2>(PathArrow<State, Whole2, Whole> other) {
    return other.then(this);
  }

  PathArrow<State, Whole, (Part, Part2)> zip<Part2>(PathArrow<State, Whole, Part2> other) {
    return PathArrow.fromRun((tuple) {
      IMap<FList<String>, (State, (Part, Part2))> out = const IMap.empty();
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

  static PathArrow<State, Whole, Never> zero<State, Whole>() {
    return PathArrow.fromRun(constfunc(const IMap.empty()));
  }

  PathArrow<State, Whole, Either<Part, Part2>> altMerge<Part2>(PathArrow<State, Whole, Part2> other) {
    return PathArrow.fromRun((tuple) {
      final arr1 = rmap(Either.left<Part, Part2>);
      final arr2 = other.rmap(Either.right<Part, Part2>);

      final map1 = arr1.run(tuple);
      final map2 = arr2.run(tuple);

      return map1.addAll(map2);
    });
  }

  PathArrow<State, Whole, Either<Part, Part2>> altLeftBiased<Part2>(PathArrow<State, Whole, Part2> other) {
    return PathArrow.fromRun((tuple) {
      final map = rmap(Either.left<Part, Part2>).run(tuple);
      if (map.isNotEmpty) {
        return map;
      }

      return other.rmap(Either.right<Part, Part2>).run(tuple);
    });
  }

  static PathArrow<E, Whole, (int, Part)> altAllLeftBiased<E, Whole, Part>(IList<PathArrow<E, Whole, Part>> list) {
    return list.indexed.fold(PathArrow.zero(), (current, element) {
      final (index, option) = element;
      final arr = option.rmap((value) => (index, value));
      return current.altLeftBiased(arr).rmap((either) {
        return either.value();
      });
    });
  }

  static PathArrow<E, Whole, (int, Part)> altAllMerge<E, Whole, Part>(IList<PathArrow<E, Whole, Part>> list) {
    return list.indexed.fold(PathArrow.zero(), (current, element) {
      final (index, option) = element;
      final arr = option.rmap((value) => (index, value));
      return current.altMerge(arr).rmap((either) {
        return either.value();
      });
    });
  }
}
