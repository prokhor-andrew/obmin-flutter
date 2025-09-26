// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/flist.dart';
import 'package:obmin/types/func.dart';

final class FListArrow<Whole, Part> {
  final Func<Whole, FList<Part>> run;

  const FListArrow._(this.run);

  static FListArrow<Whole, Part> fromRun<Whole, Part>(Func<Whole, FList<Part>> run) {
    return FListArrow._(run);
  }

  static FListArrow<Whole, ()> unit<Whole>() {
    return FListArrow.fromRun(constfunc(FList(())));
  }

  static FListArrow<A, A> id<A>() {
    return FListArrow.fromRun(FList.of);
  }

  FListArrow<Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return FListArrow.fromRun((whole) {
      return run(whole).rmap(f);
    });
  }

  FListArrow<Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return FListArrow.fromRun((whole2) {
      return run(f(whole2));
    });
  }

  FListArrow<Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap(lf).rmap(rf);
  }

  FListArrow<Whole, Sub> then<Sub>(FListArrow<Part, Sub> other) {
    return FListArrow.fromRun((whole) {
      return run(whole).bind(other.run);
    });
  }

  FListArrow<Whole2, Part> after<Whole2>(FListArrow<Whole2, Whole> other) {
    return other.then(this);
  }

  FListArrow<Whole, (Part, Part2)> zipCrossJoin<Part2>(FListArrow<Whole, Part2> other) {
    return FListArrow.fromRun((whole) {
      return run(whole).zipCrossJoin(other.run(whole));
    });
  }

  FListArrow<Whole, (Part, Part2)> zipPointIndex<Part2>(FListArrow<Whole, Part2> other) {
    return FListArrow.fromRun((whole) {
      return run(whole).zipPointIndex(other.run(whole));
    });
  }

  static FListArrow<Whole, IList<Part>> zipAllCrossJoin<Whole, Part>(IList<FListArrow<Whole, Part>> list) {
    return list.fold(FListArrow.id(), (current, element) {
      final listInOption = element.rmap((value) => [value].lock);
      return current.zipCrossJoin(listInOption).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static FListArrow<Whole, IList<Part>> zipAllPointIndex<Whole, Part>(IList<FListArrow<Whole, Part>> list) {
    return list.fold(FListArrow.id(), (current, element) {
      final arrow = element.rmap((value) => [value].lock);
      return current.zipCrossJoin(arrow).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }
}
