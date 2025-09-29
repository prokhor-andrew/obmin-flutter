// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/call.dart';
import 'package:obmin/types/dict.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/logger.dart';
import 'package:obmin/types/option.dart';
import 'package:obmin/types/result.dart';
import 'package:obmin/types/these.dart';
import 'package:obmin/types/validator.dart';
import 'package:obmin/types/writer.dart';

final class PathArrow<Whole, Part> {
  final Func<Whole, IMap<IList<String>, Part>> run;

  const PathArrow._(this.run);

  static PathArrow<Whole, Part> fromRun<Whole, Part>(
    Func<Whole, IMap<IList<String>, Part>> run,
  ) {
    return PathArrow._(run);
  }

  static PathArrow<Whole, Part> fromFunc<Whole, Part>(Func<Whole, Part> f) {
    return fromRun((whole) {
      final part = f(whole);
      return {
        const IList<String>.empty(): part,
      }.lock;
    });
  }

  static PathArrow<Either<E, Part>, Part> eitherRight<E, Part>() {
    return PathArrow.fromRun((either) {
      return either.match(
        constfunc(const IMap.empty()),
        (value) {
          return {
            ["right"].lock: value
          }.lock;
        },
      );
    });
  }

  static PathArrow<Either<Part, E>, Part> eitherLeft<E, Part>() {
    return PathArrow.fromRun((either) {
      return either.match(
        (value) {
          return {
            ["left"].lock: value
          }.lock;
        },
        constfunc(const IMap.empty()),
      );
    });
  }

  static PathArrow<Call<E, Part>, Part> callReturned<E, Part>() {
    return PathArrow.fromRun((call) {
      return call.match(
        constfunc(const IMap.empty()),
        (value) {
          return {
            ["returned"].lock: value
          }.lock;
        },
      );
    });
  }

  static PathArrow<Call<Part, E>, Part> callLaunched<E, Part>() {
    return PathArrow.fromRun((call) {
      return call.match(
        (value) {
          return {
            ["launched"].lock: value
          }.lock;
        },
        constfunc(const IMap.empty()),
      );
    });
  }

  static PathArrow<Result<E, Part>, Part> resultSuccess<E, Part>() {
    return PathArrow.fromRun((result) {
      return result.match(
        constfunc(const IMap.empty()),
        (value) {
          return {
            ["success"].lock: value
          }.lock;
        },
      );
    });
  }

  static PathArrow<Result<Part, E>, Part> resultFailure<E, Part>() {
    return PathArrow.fromRun((result) {
      return result.match(
        (value) {
          return {
            ["failure"].lock: value
          }.lock;
        },
        constfunc(const IMap.empty()),
      );
    });
  }

  static PathArrow<Writer<E, Part>, Part> writerValue<E, Part>() {
    return PathArrow.fromRun((writer) {
      return {
        ["value"].lock: writer.value()
      }.lock;
    });
  }

  static PathArrow<Writer<Part, E>, IList<Part>> writerList<E, Part>() {
    return PathArrow.fromRun((writer) {
      return {
        ["list"].lock: writer.list()
      }.lock;
    });
  }

  static PathArrow<Validator<E, Part>, Part> validatorValue<E, Part>() {
    return PathArrow.fromRun((validator) {
      return validator.match(constfunc(const IMap.empty()), (value) {
        return {
          ["value"].lock: value
        }.lock;
      });
    });
  }

  static PathArrow<Validator<Part, E>, IList<Part>> validatorErrors<E, Part>() {
    return PathArrow.fromRun((validator) {
      return validator.match((errors) {
        return {
          ["errors"].lock: errors
        }.lock;
      }, constfunc(const IMap.empty()));
    });
  }

  static PathArrow<Logger<Part>, Part> logger<Part>() {
    return PathArrow.fromRun((logger) {
      return {
        ["value"].lock: logger.value()
      }.lock;
    });
  }

  static PathArrow<Option<Part>, Part> option<Part>() {
    return PathArrow.fromRun((option) {
      return option.match(
        IMap.empty,
        (value) {
          return {
            ["some"].lock: value
          }.lock;
        },
      );
    });
  }

  static PathArrow<IList<Part>, Part> list<Part>() {
    return PathArrow.fromRun((list) {
      IMap<IList<String>, Part> result = const IMap.empty();

      list.indexed.forEach((tuple) {
        final (index, value) = tuple;
        result = result.add(["$index"].lock, value);
      });

      return result;
    });
  }

  static PathArrow<IMap<Key, Part>, Part> dict<Key, Part>() {
    return PathArrow.fromRun((map) {
      return map.map((key, value) => MapEntry([key.toString()].lock, value));
    });
  }

  static PathArrow<(E, Part), Part> tupleRight<E, Part>() {
    return PathArrow.fromRun((tuple) {
      return {
        ["right"].lock: tuple.$2,
      }.lock;
    });
  }

  static PathArrow<(Part, E), Part> tupleLeft<E, Part>() {
    return PathArrow.fromRun((tuple) {
      return {
        ["left"].lock: tuple.$1,
      }.lock;
    });
  }

  static PathArrow<These<E, Part>, Part> theseRight<E, Part>() {
    return PathArrow.fromRun((these) {
      return these.match(
        (left) {
          return const IMap.empty();
        },
        (right) {
          return {
            ["right"].lock: right
          }.lock;
        },
        (_, right) {
          return {
            ["right"].lock: right
          }.lock;
        },
      );
    });
  }

  static PathArrow<These<Part, E>, Part> theseLeft<E, Part>() {
    return PathArrow.fromRun((these) {
      return these.match(
        (left) {
          return {
            ["left"].lock: left
          }.lock;
        },
        (right) {
          return const IMap.empty();
        },
        (left, _) {
          return {
            ["left"].lock: left
          }.lock;
        },
      );
    });
  }

  PathArrow<Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return PathArrow.fromRun((tuple) {
      return run(tuple).map((key, value) => MapEntry(key, f(value)));
    });
  }

  PathArrow<Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return PathArrow.fromRun((tuple) {
      return run(f(tuple));
    });
  }

  PathArrow<Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap(lf).rmap(rf);
  }

  static PathArrow<A, A> id<A>() {
    return PathArrow.fromRun((tuple) {
      return {const IList<String>.empty(): tuple}.lock;
    });
  }

  PathArrow<Whole, Sub> then<Sub>(PathArrow<Part, Sub> other) {
    return PathArrow.fromRun((tuple) {
      IMap<IList<String>, Sub> result = const IMap.empty();

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

  PathArrow<Whole2, Part> after<Whole2>(PathArrow<Whole2, Whole> other) {
    return other.then(this);
  }

  static PathArrow<Whole, ()> unit<Whole>() {
    return PathArrow.fromRun((tuple) {
      return {const IList<String>.empty(): ()}.lock;
    });
  }

  PathArrow<Whole, (Part, Part2)> zipCrossJoin<Part2>(PathArrow<Whole, Part2> other) {
    return PathArrow.fromRun((whole) {
      IMap<IList<String>, (Part, Part2)> out = const IMap.empty();
      for (final w1 in run(whole).entries) {
        final (log1, p1) = (w1.key, w1.value);
        for (final w2 in other.run(whole).entries) {
          final (log2, p2) = (w2.key, w2.value);
          out = out.add(log1.addAll(log2), (p1, p2));
        }
      }
      return out;
    });
  }

  PathArrow<Whole, (Part, Part2)> zipLeftBias<Part2>(PathArrow<Whole, Part2> other) {
    return PathArrow.fromRun((whole) {
      IMap<IList<String>, (Part, Part2)> out = const IMap.empty();
      for (final w1 in run(whole).entries) {
        final (log1, p1) = (w1.key, w1.value);
        for (final w2 in other.run(whole).entries) {
          final (log2, p2) = (w2.key, w2.value);
          out = out.add(log1.isNotEmpty ? log1 : log2, (p1, p2));
        }
      }
      return out;
    });
  }

  static PathArrow<Whole, IList<Part>> zipAllCrossJoin<Whole, Part>(IList<PathArrow<Whole, Part>> list) {
    return list.fold(PathArrow.id(), (current, element) {
      final arrow = element.rmap((value) => [value].lock);
      return current.zipCrossJoin(arrow).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static PathArrow<Whole, IList<Part>> zipAllLeftBias<Whole, Part>(IList<PathArrow<Whole, Part>> list) {
    return list.fold(PathArrow.id(), (current, element) {
      final arrow = element.rmap((value) => [value].lock);
      return current.zipLeftBias(arrow).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static PathArrow<Whole, Never> zero<Whole>() {
    return PathArrow.fromRun(constfunc(const IMap.empty()));
  }

  PathArrow<Whole, Either<Part, Part2>> altMerge<Part2>(PathArrow<Whole, Part2> other) {
    return PathArrow.fromRun((tuple) {
      final arr1 = rmap(Either.left<Part, Part2>);
      final arr2 = other.rmap(Either.right<Part, Part2>);

      final map1 = arr1.run(tuple);
      final map2 = arr2.run(tuple);

      return map1.addAll(map2);
    });
  }

  PathArrow<Whole, Either<Part, Part2>> altLeftBiased<Part2>(PathArrow<Whole, Part2> other) {
    return PathArrow.fromRun((tuple) {
      final map = rmap(Either.left<Part, Part2>).run(tuple);
      if (map.isNotEmpty) {
        return map;
      }

      return other.rmap(Either.right<Part, Part2>).run(tuple);
    });
  }

  static PathArrow<Whole, (int, Part)> altAllLeftBiased<Whole, Part>(IList<PathArrow<Whole, Part>> list) {
    return list.indexed.fold(PathArrow.zero(), (current, element) {
      final (index, option) = element;
      final arr = option.rmap((value) => (index, value));
      return current.altLeftBiased(arr).rmap((either) {
        return either.value();
      });
    });
  }

  static PathArrow<Whole, (int, Part)> altAllMerge<Whole, Part>(IList<PathArrow<Whole, Part>> list) {
    return list.indexed.fold(PathArrow.zero(), (current, element) {
      final (index, option) = element;
      final arr = option.rmap((value) => (index, value));
      return current.altMerge(arr).rmap((either) {
        return either.value();
      });
    });
  }

  PathArrow<(A, Whole), (A, Part)> strong<A>() {
    return PathArrow.fromRun((tuple) {
      final (a, whole) = tuple;
      final map = run(whole);
      return map.rmap((part) => (a, part));
    });
  }

  PathArrow<Either<A, Whole>, Either<A, Part>> choice<A>() {
    return PathArrow.fromRun((either) {
      return either.match((a) {
        return {const IList<String>.empty(): Either.left<A, Part>(a)}.lock;
      }, (whole) {
        final map = run(whole);
        return map.rmap((part) => Either.right(part));
      });
    });
  }
}
