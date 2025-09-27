// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/list.dart';

final class ListArrow<Whole, Part> {
  final Func<Whole, IList<Part>> run;

  const ListArrow._(this.run);

  static ListArrow<Whole, Part> fromRun<Whole, Part>(Func<Whole, IList<Part>> run) {
    return ListArrow._(run);
  }

  static ListArrow<Whole, ()> unit<Whole>() {
    return ListArrow.fromRun(constfunc([()].lock));
  }

  static ListArrow<Whole, Never> zero<Whole>() {
    return ListArrow.fromRun(constfunc(const IList.empty()));
  }

  static ListArrow<A, A> id<A>() {
    return ListArrow.fromRun((value) => [value].lock);
  }

  ListArrow<Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return ListArrow.fromRun((whole) {
      return run(whole).rmap(f);
    });
  }

  ListArrow<Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return ListArrow.fromRun((whole2) {
      return run(f(whole2));
    });
  }

  ListArrow<Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap(lf).rmap(rf);
  }

  ListArrow<Whole, Sub> then<Sub>(ListArrow<Part, Sub> other) {
    return ListArrow.fromRun((whole) {
      return run(whole).bind(other.run);
    });
  }

  ListArrow<Whole2, Part> after<Whole2>(ListArrow<Whole2, Whole> other) {
    return other.then(this);
  }

  ListArrow<Whole, (Part, Part2)> zipCrossJoin<Part2>(ListArrow<Whole, Part2> other) {
    return ListArrow.fromRun((whole) {
      return run(whole).zipCrossJoin(other.run(whole));
    });
  }

  ListArrow<Whole, (Part, Part2)> zipPointIndex<Part2>(ListArrow<Whole, Part2> other) {
    return ListArrow.fromRun((whole) {
      return run(whole).zipPointIndex(other.run(whole));
    });
  }

  ListArrow<Whole, Either<Part, Part2>> altConcat<Part2>(ListArrow<Whole, Part2> other) {
    return ListArrow.fromRun((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return part.altConcat(part2);
    });
  }

  ListArrow<Whole, Either<Part, Part2>> altLeftBiased<Part2>(ListArrow<Whole, Part2> other) {
    return ListArrow.fromRun((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return part.altLeftBiased(part2);
    });
  }

  static ListArrow<Whole, IList<Part>> zipAllCrossJoin<Whole, Part>(IList<ListArrow<Whole, Part>> list) {
    return list.fold(ListArrow.id(), (current, element) {
      final listInOption = element.rmap((value) => [value].lock);
      return current.zipCrossJoin(listInOption).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static ListArrow<Whole, IList<Part>> zipAllPointIndex<Whole, Part>(IList<ListArrow<Whole, Part>> list) {
    return list.fold(ListArrow.id(), (current, element) {
      final arrow = element.rmap((value) => [value].lock);
      return current.zipCrossJoin(arrow).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static ListArrow<Whole, (int, Part)> altAllLeftBiased<Whole, Part>(IList<ListArrow<Whole, Part>> list) {
    return list.indexed.fold(ListArrow.id(), (current, element) {
      final (index, option) = element;
      final indexedOption = option.rmap((value) => (index, value));
      return current.altLeftBiased(indexedOption).rmap((either) {
        return either.value();
      });
    });
  }

  static ListArrow<Whole, (int, Part)> altAllConcat<Whole, Part>(IList<ListArrow<Whole, Part>> list) {
    return list.indexed.fold(ListArrow.id(), (current, element) {
      final (index, option) = element;
      final indexedOption = option.rmap((value) => (index, value));
      return current.altConcat(indexedOption).rmap((either) {
        return either.value();
      });
    });
  }
}
