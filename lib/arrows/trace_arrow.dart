// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/list.dart';
import 'package:obmin/types/tuple.dart';
import 'package:obmin/types/writer.dart';

final class TraceArrow<State, Whole, Part> {
  final Func<(State, Whole), IList<Writer<String, (State, Part)>>> run;

  const TraceArrow(this.run);

  static TraceArrow<State, Whole, ()> unit<State, Whole>() {
    return TraceArrow((tuple) {
      return [Writer.of<String, (State, ())>((tuple.$1, ()))].lock;
    });
  }

  static TraceArrow<State, Whole, Never> zero<State, Whole>() {
    return TraceArrow(constfunc(const IList.empty()));
  }

  static TraceArrow<State, A, A> id<State, A>() {
    return TraceArrow((tuple) {
      return [Writer<String, (State, A)>(const IList.empty(), tuple)].lock;
    });
  }

  TraceArrow<State, Whole, C> rmap<C>(Func<Part, C> f) {
    return TraceArrow((tuple) {
      return run(tuple).rmap((writer) {
        return writer.rmap((tuple) {
          return tuple.rmap(f);
        });
      });
    });
  }

  TraceArrow<State, Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return TraceArrow((tuple) {
      return run(tuple.rmap(f));
    });
  }

  TraceArrow<State2, Whole, Part> imap<State2>(Func<State2, State> lf, Func<State, State2> rf) {
    return TraceArrow((tuple) {
      final list = run(tuple.lmap(lf));

      return list.rmap((writer) {
        return writer.rmap((tuple) {
          return tuple.lmap(rf);
        });
      });
    });
  }

  TraceArrow<State, Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap(lf).rmap(rf);
  }

  TraceArrow<State, Whole, C> then<C>(TraceArrow<State, Part, C> other) {
    return TraceArrow((tuple) {
      return run(tuple).bind((writer) {
        return other.run(writer.value).rmap((writer2) {
          return Writer(writer.list.addAll(writer2.list), writer2.value);
        });
      });
    });
  }

  TraceArrow<State, Whole2, Part> after<Whole2>(TraceArrow<State, Whole2, Whole> other) {
    return other.then(this);
  }

  TraceArrow<State, Whole, (Part, Part2)> zipWith<Part2>(TraceArrow<State, Whole, Part2> other) {
    return TraceArrow((sw) {
      IList<Writer<String, (State, (Part, Part2))>> out = const IList.empty();
      for (final w1 in run(sw)) {
        final (log1, (s1, p1)) = (w1.list, w1.value);
        for (final w2 in other.run((s1, sw.$2))) {
          final (log2, (s2, p2)) = (w2.list, w2.value);
          out = out.add(Writer(log1.addAll(log2), (s2, (p1, p2))));
        }
      }
      return out;
    });
  }

  TraceArrow<State, Whole, Either<Part, Part2>> altWithConcat<Part2>(TraceArrow<State, Whole, Part2> other) {
    return TraceArrow((tuple) {
      final arr1 = rmap(Either.left<Part, Part2>);
      final arr2 = other.rmap(Either.right<Part, Part2>);

      return arr1.run(tuple).addAll(arr2.run(tuple));
    });
  }

  TraceArrow<State, Whole, Either<Part, Part2>> altWithLeftBiased<Part2>(TraceArrow<State, Whole, Part2> other) {
    return TraceArrow((tuple) {
      return rmap(Either.left<Part, Part2>).run(tuple);
    });
  }
}
