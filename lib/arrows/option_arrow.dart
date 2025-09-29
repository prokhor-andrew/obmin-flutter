// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/arrows/either_arrow.dart';
import 'package:obmin/arrows/list_arrow.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/option.dart';

final class OptionArrow<Whole, Part> {
  final Func<Whole, Option<Part>> run;

  const OptionArrow._(this.run);

  static OptionArrow<Whole, Part> fromRun<Whole, Part>(Func<Whole, Option<Part>> run) {
    return OptionArrow._(run);
  }

  static OptionArrow<Whole, Part> fromFunc<Whole, Part>(Func<Whole, Part> f) {
    return fromRun<Whole, Part>((whole) {
      final part = f(whole);
      return OptionArrow.id<Part>().run(part);
    });
  }

  static OptionArrow<A, A> id<A>() {
    return OptionArrow.fromRun<A, A>(Option.some);
  }

  static OptionArrow<Whole, ()> unit<Whole>() {
    return OptionArrow.fromRun<Whole, ()>(constfunc<Whole, Option<()>>(Option.some(())));
  }

  static OptionArrow<Whole, Never> zero<Whole>() {
    return OptionArrow.fromRun<Whole, Never>(constfunc<Whole, Option<Never>>(Option.none()));
  }

  OptionArrow<Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return OptionArrow.fromRun<Whole, Part2>((whole) {
      return run(whole).rmap<Part2>(f);
    });
  }

  OptionArrow<Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return OptionArrow.fromRun<Whole2, Part>((whole2) {
      return run(f(whole2));
    });
  }

  OptionArrow<Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap<Whole2>(lf).rmap<Part2>(rf);
  }

  OptionArrow<Whole, Sub> then<Sub>(OptionArrow<Part, Sub> other) {
    return OptionArrow.fromRun<Whole, Sub>((whole) {
      return run(whole).bind<Sub>(other.run);
    });
  }

  OptionArrow<Whole2, Part> after<Whole2>(OptionArrow<Whole2, Whole> other) {
    return other.then<Part>(this);
  }

  OptionArrow<Whole, (Part, Part2)> zip<Part2>(OptionArrow<Whole, Part2> other) {
    return OptionArrow.fromRun<Whole, (Part, Part2)>((whole) {
      return run(whole).zip<Part2>(other.run(whole));
    });
  }

  OptionArrow<Whole, Either<Part, Part2>> alt<Part2>(OptionArrow<Whole, Part2> other) {
    return OptionArrow.fromRun<Whole, Either<Part, Part2>>((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return part.alt<Part2>(part2);
    });
  }

  static OptionArrow<Whole, IList<Part>> zipAll<Whole, Part>(IList<OptionArrow<Whole, Part>> list) {
    return list.fold<OptionArrow<Whole, IList<Part>>>(OptionArrow.fromRun<Whole, IList<Part>>((_) => Option.some<IList<Part>>(IList<Part>.empty())), (current, element) {
      final arrow = element.rmap<IList<Part>>((value) => [value].lock);
      return current.zip(arrow).rmap<IList<Part>>((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static OptionArrow<Whole, (int, Part)> altAll<Whole, Part>(IList<OptionArrow<Whole, Part>> list) {
    return list.indexed.fold<OptionArrow<Whole, (int, Part)>>(OptionArrow.fromRun<Whole, (int, Part)>((_) => Option.none<(int, Part)>()), (current, element) {
      final (index, option) = element;
      final indexedOption = option.rmap<(int, Part)>((value) => (index, value));
      return current.alt(indexedOption).rmap<(int, Part)>((either) {
        return either.value();
      });
    });
  }

  ListArrow<Whole, Part> asListArrow() {
    return ListArrow.fromRun<Whole, Part>((whole) {
      return run(whole).match<IList<Part>>(IList<Part>.empty, (value) => [value].lock);
    });
  }

  EitherArrow<(), Whole, Part> asEitherArrow() {
    return EitherArrow.fromRun<(), Whole, Part>((whole) {
      return run(whole).match<Either<(), Part>>(() => Either.left<(), Part>(()), Either.right<(), Part>);
    });
  }

  OptionArrow<(A, Whole), (A, Part)> strong<A>() {
    return OptionArrow.fromRun<(A, Whole), (A, Part)>((tuple) {
      final (a, whole) = tuple;
      final functor = run(whole);
      return functor.rmap<(A, Part)>((part) => (a, part));
    });
  }

  OptionArrow<Either<A, Whole>, Either<A, Part>> choice<A>() {
    return OptionArrow.fromRun<Either<A, Whole>, Either<A, Part>>((either) {
      return either.match<Option<Either<A, Part>>>((a) {
        return OptionArrow.id<Either<A, Part>>().run(Either.left<A, Part>(a));
      }, (whole) {
        final functor = run(whole);
        return functor.rmap<Either<A, Part>>((part) => Either.right<A, Part>(part));
      });
    });
  }
}
