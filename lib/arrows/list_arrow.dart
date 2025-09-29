// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/list.dart';

final class ListArrow<Whole, Part> {
  final Func<Whole, IList<Part>> run;

  const ListArrow._(this.run);

  static ListArrow<Whole, Part> fromRun<Whole, Part>(Func<Whole, IList<Part>> run) {
    return ListArrow._(run);
  }

  static ListArrow<Whole, Part> fromFunc<Whole, Part>(Func<Whole, Part> f) {
    return fromRun<Whole, Part>((whole) {
      final part = f(whole);
      return ListArrow.id<Part>().run(part);
    });
  }

  static ListArrow<Whole, ()> unit<Whole>() {
    return ListArrow.fromRun<Whole, ()>(constfunc([()].lock));
  }

  static ListArrow<Whole, Never> zero<Whole>() {
    return ListArrow.fromRun<Whole, Never>(constfunc(const IList<Never>.empty()));
  }

  static ListArrow<A, A> id<A>() {
    return ListArrow.fromRun<A, A>((value) => [value].lock);
  }

  ListArrow<Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return ListArrow.fromRun<Whole, Part2>((whole) {
      return run(whole).rmap<Part2>(f);
    });
  }

  ListArrow<Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return ListArrow.fromRun<Whole2, Part>((whole2) {
      return run(f(whole2));
    });
  }

  ListArrow<Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap<Whole2>(lf).rmap<Part2>(rf);
  }

  ListArrow<Whole, Sub> then<Sub>(ListArrow<Part, Sub> other) {
    return ListArrow.fromRun<Whole, Sub>((whole) {
      return run(whole).bind<Sub>(other.run);
    });
  }

  ListArrow<Whole2, Part> after<Whole2>(ListArrow<Whole2, Whole> other) {
    return other.then<Part>(this);
  }

  ListArrow<Whole, (Part, Part2)> zipCrossJoin<Part2>(ListArrow<Whole, Part2> other) {
    return ListArrow.fromRun<Whole, (Part, Part2)>((whole) {
      return run(whole).zipCrossJoin<Part2>(other.run(whole));
    });
  }

  ListArrow<Whole, (Part, Part2)> zipPointIndex<Part2>(ListArrow<Whole, Part2> other) {
    return ListArrow.fromRun<Whole, (Part, Part2)>((whole) {
      return run(whole).zipPointIndex<Part2>(other.run(whole));
    });
  }

  ListArrow<Whole, Either<Part, Part2>> altConcat<Part2>(ListArrow<Whole, Part2> other) {
    return ListArrow.fromRun<Whole, Either<Part, Part2>>((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return part.altConcat<Part2>(part2);
    });
  }

  ListArrow<Whole, Either<Part, Part2>> altLeftBiased<Part2>(ListArrow<Whole, Part2> other) {
    return ListArrow.fromRun<Whole, Either<Part, Part2>>((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return part.altLeftBiased<Part2>(part2);
    });
  }

  static ListArrow<Whole, IList<Part>> zipAllCrossJoin<Whole, Part>(IList<ListArrow<Whole, Part>> list) {
    return list.fold<ListArrow<Whole, IList<Part>>>(ListArrow.fromRun((_) => [IList<Part>.empty()].lock), (current, element) {
      final arrow = element.rmap<IList<Part>>((value) => [value].lock);
      return current.zipCrossJoin<IList<Part>>(arrow).rmap<IList<Part>>((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static ListArrow<Whole, IList<Part>> zipAllPointIndex<Whole, Part>(IList<ListArrow<Whole, Part>> list) {
    return list.fold<ListArrow<Whole, IList<Part>>>(ListArrow.fromRun((_) => [IList<Part>.empty()].lock), (current, element) {
      final arrow = element.rmap<IList<Part>>((value) => [value].lock);
      return current.zipCrossJoin<IList<Part>>(arrow).rmap<IList<Part>>((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static ListArrow<Whole, (int, Part)> altAllLeftBiased<Whole, Part>(IList<ListArrow<Whole, Part>> list) {
    return list.indexed.fold<ListArrow<Whole, (int, Part)>>(ListArrow.fromRun((_) => <(int, Part)>[].lock), (current, element) {
      final (index, option) = element;
      final arrow = option.rmap<(int, Part)>((value) => (index, value));
      return current.altLeftBiased<(int, Part)>(arrow).rmap<(int, Part)>((either) {
        return either.value();
      });
    });
  }

  static ListArrow<Whole, (int, Part)> altAllConcat<Whole, Part>(IList<ListArrow<Whole, Part>> list) {
    return list.indexed.fold(ListArrow.fromRun((_) => <(int, Part)>[].lock), (current, element) {
      final (index, option) = element;
      final arrow = option.rmap<(int, Part)>((value) => (index, value));
      return current.altConcat<(int, Part)>(arrow).rmap<(int, Part)>((either) {
        return either.value();
      });
    });
  }

  ListArrow<(A, Whole), (A, Part)> strong<A>() {
    return ListArrow.fromRun<(A, Whole), (A, Part)>((tuple) {
      final (a, whole) = tuple;
      final functor = run(whole);
      return functor.rmap<(A, Part)>((part) => (a, part));
    });
  }

  ListArrow<Either<A, Whole>, Either<A, Part>> choice<A>() {
    return ListArrow.fromRun<Either<A, Whole>, Either<A, Part>>((either) {
      return either.match<IList<Either<A, Part>>>((a) {
        return ListArrow.id<Either<A, Part>>().run(Either.left<A, Part>(a));
      }, (whole) {
        final functor = run(whole);
        return functor.rmap<Either<A, Part>>((part) => Either.right<A, Part>(part));
      });
    });
  }
}
