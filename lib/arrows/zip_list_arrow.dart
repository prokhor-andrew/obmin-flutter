// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/zip_list.dart';

final class ZipListArrow<Whole, Part> {
  final Func<Whole, ZipList<Part>> run;

  const ZipListArrow._(this.run);

  static ZipListArrow<Whole, Part> fromRun<Whole, Part>(Func<Whole, ZipList<Part>> run) {
    return ZipListArrow._(run);
  }

  static ZipListArrow<Whole, Part> fromFunc<Whole, Part>(Func<Whole, Part> f) {
    return fromRun<Whole, Part>((whole) {
      final part = f(whole);
      return ZipList.infinite(part);
    });
  }

  static ZipListArrow<Whole, ()> unit<Whole>() {
    return ZipListArrow.fromRun<Whole, ()>(constfunc(ZipList.unit()));
  }

  ZipListArrow<Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return ZipListArrow.fromRun<Whole, Part2>((whole) {
      return run(whole).rmap<Part2>(f);
    });
  }

  ZipListArrow<Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return ZipListArrow.fromRun<Whole2, Part>((whole2) {
      return run(f(whole2));
    });
  }

  ZipListArrow<Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap<Whole2>(lf).rmap<Part2>(rf);
  }

  ZipListArrow<Whole, (Part, Part2)> zip<Part2>(ZipListArrow<Whole, Part2> other) {
    return ZipListArrow.fromRun<Whole, (Part, Part2)>((whole) {
      return run(whole).zip<Part2>(other.run(whole));
    });
  }

  static ZipListArrow<Whole, IList<Part>> zipAll<Whole, Part>(IList<ZipListArrow<Whole, Part>> list) {
    return list.fold<ZipListArrow<Whole, IList<Part>>>(ZipListArrow.fromRun<Whole, IList<Part>>((_) => ZipList.infinite(IList<Part>.empty())), (current, element) {
      final arrow = element.rmap<IList<Part>>((value) => [value].lock);
      return current.zip<IList<Part>>(arrow).rmap<IList<Part>>((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  ZipListArrow<(A, Whole), (A, Part)> strong<A>() {
    return ZipListArrow.fromRun<(A, Whole), (A, Part)>((tuple) {
      final (a, whole) = tuple;
      final functor = run(whole);
      return functor.rmap<(A, Part)>((part) => (a, part));
    });
  }

  ZipListArrow<Either<A, Whole>, Either<A, Part>> choice<A>() {
    return ZipListArrow.fromRun<Either<A, Whole>, Either<A, Part>>((either) {
      return either
          .lmap(Either.left<A, Part>)
          .lmap(ZipList.infinite)
          .rmap(run)
          .rmap((list) => list.rmap(Either.right<A, Part>)) //
          .value();
    });
  }
}
