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
    return PathArrow.fromRun<Whole, Part>((whole) {
      final part = f(whole);
      return PathArrow.id<Part>().run(part);
    });
  }

  static PathArrow<Either<E, Part>, Part> eitherRight<E, Part>() {
    return PathArrow.fromRun<Either<E, Part>, Part>((either) {
      return either.match<IMap<IList<String>, Part>>(
        constfunc(IMap<IList<String>, Part>.empty()),
        (value) {
          return {
            ["right"].lock: value
          }.lock;
        },
      );
    });
  }

  static PathArrow<Either<Part, E>, Part> eitherLeft<E, Part>() {
    return PathArrow.fromRun<Either<Part, E>, Part>((either) {
      return either.match<IMap<IList<String>, Part>>(
        (value) {
          return {
            ["left"].lock: value
          }.lock;
        },
        constfunc(IMap<IList<String>, Part>.empty()),
      );
    });
  }

  static PathArrow<Call<E, Part>, Part> callReturned<E, Part>() {
    return PathArrow.fromRun<Call<E, Part>, Part>((call) {
      return call.match<IMap<IList<String>, Part>>(
        constfunc(IMap<IList<String>, Part>.empty()),
        (value) {
          return {
            ["returned"].lock: value
          }.lock;
        },
      );
    });
  }

  static PathArrow<Call<Part, E>, Part> callLaunched<E, Part>() {
    return PathArrow.fromRun<Call<Part, E>, Part>((call) {
      return call.match<IMap<IList<String>, Part>>(
        (value) {
          return {
            ["launched"].lock: value
          }.lock;
        },
        constfunc(IMap<IList<String>, Part>.empty()),
      );
    });
  }

  static PathArrow<Result<E, Part>, Part> resultSuccess<E, Part>() {
    return PathArrow.fromRun<Result<E, Part>, Part>((result) {
      return result.match<IMap<IList<String>, Part>>(
        constfunc(IMap<IList<String>, Part>.empty()),
        (value) {
          return {
            ["success"].lock: value
          }.lock;
        },
      );
    });
  }

  static PathArrow<Result<Part, E>, Part> resultFailure<E, Part>() {
    return PathArrow.fromRun<Result<Part, E>, Part>((result) {
      return result.match<IMap<IList<String>, Part>>(
        (value) {
          return {
            ["failure"].lock: value
          }.lock;
        },
        constfunc(IMap<IList<String>, Part>.empty()),
      );
    });
  }

  static PathArrow<Writer<E, Part>, Part> writerValue<E, Part>() {
    return PathArrow.fromRun<Writer<E, Part>, Part>((writer) {
      return {
        ["value"].lock: writer.value()
      }.lock;
    });
  }

  static PathArrow<Writer<Part, E>, IList<Part>> writerList<E, Part>() {
    return PathArrow.fromRun<Writer<Part, E>, IList<Part>>((writer) {
      return {
        ["list"].lock: writer.list()
      }.lock;
    });
  }

  static PathArrow<Validator<E, Part>, Part> validatorValue<E, Part>() {
    return PathArrow.fromRun<Validator<E, Part>, Part>((validator) {
      return validator.match(constfunc(IMap<IList<String>, Part>.empty()), (value) {
        return {
          ["value"].lock: value
        }.lock;
      });
    });
  }

  static PathArrow<Validator<Part, E>, IList<Part>> validatorErrors<E, Part>() {
    return PathArrow.fromRun<Validator<Part, E>, IList<Part>>((validator) {
      return validator.match<IMap<IList<String>, IList<Part>>>((errors) {
        return {
          ["errors"].lock: errors
        }.lock;
      }, constfunc(IMap<IList<String>, IList<Part>>.empty()));
    });
  }

  static PathArrow<Logger<Part>, Part> logger<Part>() {
    return PathArrow.fromRun<Logger<Part>, Part>((logger) {
      return {
        ["value"].lock: logger.value()
      }.lock;
    });
  }

  static PathArrow<Option<Part>, Part> option<Part>() {
    return PathArrow.fromRun<Option<Part>, Part>((option) {
      return option.match(
        IMap<IList<String>, Part>.empty,
        (value) {
          return {
            ["some"].lock: value
          }.lock;
        },
      );
    });
  }

  static PathArrow<IList<Part>, Part> list<Part>() {
    return PathArrow.fromRun<IList<Part>, Part>((list) {
      IMap<IList<String>, Part> result = IMap<IList<String>, Part>.empty();

      list.indexed.forEach((tuple) {
        final (index, value) = tuple;
        result = result.add(["$index"].lock, value);
      });

      return result;
    });
  }

  static PathArrow<IMap<Key, Part>, Part> dict<Key, Part>() {
    return PathArrow.fromRun<IMap<Key, Part>, Part>((map) {
      return map.map<IList<String>, Part>((key, value) => MapEntry([key.toString()].lock, value));
    });
  }

  static PathArrow<(E, Part), Part> tupleRight<E, Part>() {
    return PathArrow.fromRun<(E, Part), Part>((tuple) {
      return {
        ["right"].lock: tuple.$2,
      }.lock;
    });
  }

  static PathArrow<(Part, E), Part> tupleLeft<E, Part>() {
    return PathArrow.fromRun<(Part, E), Part>((tuple) {
      return {
        ["left"].lock: tuple.$1,
      }.lock;
    });
  }

  static PathArrow<These<E, Part>, Part> theseRight<E, Part>() {
    return PathArrow.fromRun<These<E, Part>, Part>((these) {
      return these.match<IMap<IList<String>, Part>>(
        (left) => IMap<IList<String>, Part>.empty(),
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
    return PathArrow.fromRun<These<Part, E>, Part>((these) {
      return these.match<IMap<IList<String>, Part>>(
        (left) {
          return {
            ["left"].lock: left
          }.lock;
        },
        (right) => IMap<IList<String>, Part>.empty(),
        (left, _) {
          return {
            ["left"].lock: left
          }.lock;
        },
      );
    });
  }

  PathArrow<Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return PathArrow.fromRun<Whole, Part2>((tuple) {
      return run(tuple).map<IList<String>, Part2>((key, value) => MapEntry(key, f(value)));
    });
  }

  PathArrow<Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return PathArrow.fromRun<Whole2, Part>((tuple) {
      return run(f(tuple));
    });
  }

  PathArrow<Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap<Whole2>(lf).rmap<Part2>(rf);
  }

  static PathArrow<A, A> id<A>() {
    return PathArrow.fromRun<A, A>((tuple) {
      return {const IList<String>.empty(): tuple}.lock;
    });
  }

  PathArrow<Whole, Sub> then<Sub>(PathArrow<Part, Sub> other) {
    return PathArrow.fromRun<Whole, Sub>((tuple) {
      IMap<IList<String>, Sub> result = IMap<IList<String>, Sub>.empty();

      final outerMap = run(tuple);
      for (final entry in outerMap.entries) {
        final outerKey = entry.key;
        final outerValue = entry.value;

        final IMap<IList<String>, Sub> innerMap = other.run(outerValue);
        final IMap<IList<String>, Sub> transformedMap = innerMap.map<IList<String>, Sub>((key, Sub value) => MapEntry(outerKey.addAll(key).toIList(), value));

        result = result.addAll(transformedMap);
      }

      return result;
    });
  }

  PathArrow<Whole2, Part> after<Whole2>(PathArrow<Whole2, Whole> other) {
    return other.then<Part>(this);
  }

  static PathArrow<Whole, ()> unit<Whole>() {
    return PathArrow.fromRun<Whole, ()>((tuple) {
      return {const IList<String>.empty(): ()}.lock;
    });
  }

  PathArrow<Whole, (Part, Part2)> zipPointIndex<Part2>(PathArrow<Whole, Part2> other) {
    return PathArrow.fromRun((whole) {
      IMap<IList<String>, (Part, Part2)> out = const IMap<IList<String>, (Part, Part2)>.empty();
      final map1 = run(whole);
      final map2 = other.run(whole);

      map1.forEach((k, element1) {
        final element2 = map2.get(k);
        if (element2 == null) {
          return;
        }

        out = out.add(k, (element1, element2));
      });
      return out;
    });
  }

  PathArrow<Whole, (Part, Part2)> zipCrossJoin<Part2>(PathArrow<Whole, Part2> other) {
    return PathArrow.fromRun<Whole, (Part, Part2)>((whole) {
      IMap<IList<String>, (Part, Part2)> out = const IMap<IList<String>, (Part, Part2)>.empty();
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

  static PathArrow<Whole, IList<Part>> zipAllCrossJoin<Whole, Part>(IList<PathArrow<Whole, Part>> list) {
    return list.fold<PathArrow<Whole, IList<Part>>>(PathArrow.fromRun<Whole, IList<Part>>((_) => {const IList<String>.empty(): IList<Part>.empty()}.lock), (current, element) {
      final arrow = element.rmap<IList<Part>>((value) => [value].lock);
      return current.zipCrossJoin<IList<Part>>(arrow).rmap<IList<Part>>((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static PathArrow<Whole, IList<Part>> zipAllPointIndex<Whole, Part>(IList<PathArrow<Whole, Part>> list) {
    return list.fold<PathArrow<Whole, IList<Part>>>(PathArrow.fromRun<Whole, IList<Part>>((_) => {const IList<String>.empty(): IList<Part>.empty()}.lock), (current, element) {
      final arrow = element.rmap<IList<Part>>((value) => [value].lock);
      return current.zipPointIndex<IList<Part>>(arrow).rmap<IList<Part>>((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static PathArrow<Whole, Never> zero<Whole>() {
    return PathArrow.fromRun<Whole, Never>(constfunc<Whole, IMap<IList<String>, Never>>(const IMap<IList<String>, Never>.empty()));
  }

  PathArrow<Whole, Either<Part, Part2>> altMerge<Part2>(PathArrow<Whole, Part2> other) {
    return PathArrow.fromRun<Whole, Either<Part, Part2>>((tuple) {
      final arr1 = rmap(Either.left<Part, Part2>);
      final arr2 = other.rmap(Either.right<Part, Part2>);

      final map1 = arr1.run(tuple);
      final map2 = arr2.run(tuple);

      return map1.addAll(map2);
    });
  }

  PathArrow<Whole, Either<Part, Part2>> altLeftBiased<Part2>(PathArrow<Whole, Part2> other) {
    return PathArrow.fromRun<Whole, Either<Part, Part2>>((tuple) {
      final map = rmap(Either.left<Part, Part2>).run(tuple);
      if (map.isNotEmpty) {
        return map;
      }

      return other.rmap(Either.right<Part, Part2>).run(tuple);
    });
  }

  static PathArrow<Whole, (int, Part)> altAllLeftBiased<Whole, Part>(IList<PathArrow<Whole, Part>> list) {
    return list.indexed.fold<PathArrow<Whole, (int, Part)>>(PathArrow.zero<Whole>(), (current, element) {
      final (index, arrow) = element;
      final arr = arrow.rmap<(int, Part)>((value) => (index, value));
      return current.altLeftBiased<(int, Part)>(arr).rmap<(int, Part)>((either) {
        return either.value();
      });
    });
  }

  static PathArrow<Whole, (int, Part)> altAllMerge<Whole, Part>(IList<PathArrow<Whole, Part>> list) {
    return list.indexed.fold<PathArrow<Whole, (int, Part)>>(PathArrow.zero<Whole>(), (current, element) {
      final (index, arrow) = element;
      final arr = arrow.rmap<(int, Part)>((value) => (index, value));
      return current.altMerge<(int, Part)>(arr).rmap<(int, Part)>((either) {
        return either.value();
      });
    });
  }

  PathArrow<(A, Whole), (A, Part)> strong<A>() {
    return PathArrow.fromRun<(A, Whole), (A, Part)>((tuple) {
      final (a, whole) = tuple;
      final functor = run(whole);
      return functor.rmap<(A, Part)>((part) => (a, part));
    });
  }

  PathArrow<Either<A, Whole>, Either<A, Part>> choice<A>() {
    return PathArrow.fromRun<Either<A, Whole>, Either<A, Part>>((either) {
      return either.match<IMap<IList<String>, Either<A, Part>>>((a) {
        return PathArrow.id<Either<A, Part>>().run(Either.left<A, Part>(a));
      }, (whole) {
        final functor = run(whole);
        return functor.rmap<Either<A, Part>>((part) => Either.right<A, Part>(part));
      });
    });
  }
}
