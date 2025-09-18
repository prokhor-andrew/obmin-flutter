// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/list.dart';
import 'package:obmin/types/tuple.dart';
import 'package:obmin/types/writer.dart';

final class TraceArrow<State, Whole, Part> {
  final Func<(State, Whole), IList<Writer<String, (State, Part)>>> run;

  const TraceArrow(this.run);

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
}
