// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/call.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/flist.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/logger.dart';
import 'package:obmin/types/option.dart';
import 'package:obmin/types/result.dart';
import 'package:obmin/types/these.dart';
import 'package:obmin/types/validator.dart';
import 'package:obmin/types/writer.dart';

final class PathArrow<State, Whole, Part> {
  final Func<(State, Whole), IMap<FList<String>, (State, Part)>> run;

  const PathArrow._(this.run);

  static PathArrow<State, Whole, Part> fromRun<State, Whole, Part>(
    Func<(State, Whole), IMap<FList<String>, (State, Part)>> run,
  ) {
    return PathArrow._(run);
  }

  static PathArrow<State, Either<E, Part>, Part> either<State, E, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, either) = tuple;

      return either.match(
        constfunc(const IMap.empty()),
        (value) {
          return {FList.of("right"): (state, value)}.lock;
        },
      );
    });
  }

  static PathArrow<State, Either<Part, E>, Part> eitherLeft<State, E, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, either) = tuple;

      return either.match(
        (value) {
          return {FList.of("left"): (state, value)}.lock;
        },
        constfunc(const IMap.empty()),
      );
    });
  }

  static PathArrow<State, Call<E, Part>, Part> callReturned<State, E, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, either) = tuple;

      return either.match(
        constfunc(const IMap.empty()),
        (value) {
          return {FList.of("returned"): (state, value)}.lock;
        },
      );
    });
  }

  static PathArrow<State, Call<Part, E>, Part> callLaunched<State, E, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, either) = tuple;

      return either.match(
        (value) {
          return {FList.of("launched"): (state, value)}.lock;
        },
        constfunc(const IMap.empty()),
      );
    });
  }

  static PathArrow<State, Result<E, Part>, Part> resultSuccess<State, E, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, either) = tuple;

      return either.match(
        constfunc(const IMap.empty()),
        (value) {
          return {FList.of("success"): (state, value)}.lock;
        },
      );
    });
  }

  static PathArrow<State, Result<Part, E>, Part> resultFailure<State, E, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, either) = tuple;

      return either.match(
        (value) {
          return {FList.of("failure"): (state, value)}.lock;
        },
        constfunc(const IMap.empty()),
      );
    });
  }

  static PathArrow<State, Writer<E, Part>, Part> writer<State, E, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, writer) = tuple;

      return {FList.of("value"): (state, writer.value())}.lock;
    });
  }

  static PathArrow<State, Writer<Part, E>, Part> writerList<State, E, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, writer) = tuple;

      IMap<FList<String>, (State, Part)> map = const IMap.empty();

      writer.list().indexed.forEach((tuple) {
        final (index, value) = tuple;
        map = map.add(FList.of("$index"), (state, value));
      });

      return map;
    });
  }

  static PathArrow<State, FList<Part>, Part> flist<State, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, flist) = tuple;

      IMap<FList<String>, (State, Part)> result = {FList.of("0"): (state, flist.head())}.lock;

      flist.tail().indexed.forEach((tuple) {
        final (index, value) = tuple;
        result = result.add(FList.of("${index + 1}"), (state, value));
      });

      return result;
    });
  }

  static PathArrow<State, Validator<E, Part>, Part> validator<State, E, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, validator) = tuple;

      return validator.match(constfunc(const IMap.empty()), (value) {
        return {FList.of("value"): (state, value)}.lock;
      });
    });
  }

  static PathArrow<State, Validator<Part, E>, Part> validatorErrors<State, E, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, validator) = tuple;

      return validator.match((errors) {
        IMap<FList<String>, (State, Part)> map = const IMap.empty();

        errors.indexed.forEach((tuple) {
          final (index, value) = tuple;
          map = map.add(FList.of("$index"), (state, value));
        });

        return map;
      }, constfunc(const IMap.empty()));
    });
  }

  static PathArrow<State, Logger<Part>, Part> logger<State, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, logger) = tuple;

      return {FList.of("value"): (state, logger.value())}.lock;
    });
  }

  static PathArrow<State, Option<Part>, Part> option<State, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, option) = tuple;

      return option.match(
        IMap.empty,
        (value) {
          return {FList.of("some"): (state, value)}.lock;
        },
      );
    });
  }

  static PathArrow<State, IList<Part>, Part> list<State, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, list) = tuple;

      IMap<FList<String>, (State, Part)> result = const IMap.empty();

      list.indexed.forEach((tuple) {
        final (index, value) = tuple;
        result = result.add(FList.of("$index"), (state, value));
      });

      return result;
    });
  }

  static PathArrow<State, IMap<String, Part>, Part> map<State, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, map) = tuple;

      return map.map((key, value) => MapEntry(FList.of(key), (state, value)));
    });
  }

  static PathArrow<State, (E, Part), Part> tuple<State, E, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, tuple2) = tuple;

      return {
        FList.of("right"): (state, tuple2.$2),
      }.lock;
    });
  }

  static PathArrow<State, (Part, E), Part> tupleLeft<State, E, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, tuple2) = tuple;

      return {
        FList.of("left"): (state, tuple2.$1),
      }.lock;
    });
  }

  static PathArrow<State, These<E, Part>, Part> these<State, E, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, these) = tuple;

      return these.match(
        (left) {
          return const IMap.empty();
        },
        (right) {
          return {FList.of("right"): (state, right)}.lock;
        },
        (_, right) {
          return {FList.of("right"): (state, right)}.lock;
        },
      );
    });
  }

  static PathArrow<State, These<Part, E>, Part> theseLeft<State, E, Part>() {
    return PathArrow.fromRun((tuple) {
      final (state, these) = tuple;

      return these.match(
        (left) {
          return {FList.of("left"): (state, left)}.lock;
        },
        (right) {
          return const IMap.empty();
        },
        (left, _) {
          return {FList.of("left"): (state, left)}.lock;
        },
      );
    });
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
