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
    return fromRun((whole) {
      final part = f(whole);
      return OptionArrow.id<Part>().run(part);
    });
  }

  static OptionArrow<A, A> id<A>() {
    return OptionArrow.fromRun(Option.some);
  }

  static OptionArrow<Whole, ()> unit<Whole>() {
    return OptionArrow.fromRun(constfunc(Option.some(())));
  }

  static OptionArrow<Whole, Never> zero<Whole>() {
    return OptionArrow.fromRun(constfunc(Option.none()));
  }

  OptionArrow<Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return OptionArrow.fromRun((whole) {
      return run(whole).rmap(f);
    });
  }

  OptionArrow<Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return OptionArrow.fromRun((whole2) {
      return run(f(whole2));
    });
  }

  OptionArrow<Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap(lf).rmap(rf);
  }

  OptionArrow<Whole, Sub> then<Sub>(OptionArrow<Part, Sub> other) {
    return OptionArrow.fromRun((whole) {
      return run(whole).bind(other.run);
    });
  }

  OptionArrow<Whole2, Part> after<Whole2>(OptionArrow<Whole2, Whole> other) {
    return other.then(this);
  }

  OptionArrow<Whole, (Part, Part2)> zip<Part2>(OptionArrow<Whole, Part2> other) {
    return OptionArrow.fromRun((whole) {
      return run(whole).zip(other.run(whole));
    });
  }

  OptionArrow<Whole, Either<Part, Part2>> alt<Part2>(OptionArrow<Whole, Part2> other) {
    return OptionArrow.fromRun((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return part.alt(part2);
    });
  }

  static OptionArrow<Whole, IList<Part>> zipAll<Whole, Part>(IList<OptionArrow<Whole, Part>> list) {
    return list.fold(OptionArrow.id(), (current, element) {
      final arrow = element.rmap((value) => [value].lock);
      return current.zip(arrow).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  static OptionArrow<Whole, (int, Part)> altAll<Whole, Part>(IList<OptionArrow<Whole, Part>> list) {
    return list.indexed.fold(OptionArrow.id(), (current, element) {
      final (index, option) = element;
      final indexedOption = option.rmap((value) => (index, value));
      return current.alt(indexedOption).rmap((either) {
        return either.value();
      });
    });
  }

  ListArrow<Whole, Part> asListArrow() {
    return ListArrow.fromRun((whole) {
      return run(whole).match(IList.empty, (value) => [value].lock);
    });
  }

  EitherArrow<(), Whole, Part> asEitherArrow() {
    return EitherArrow.fromRun((whole) {
      return run(whole).match(() => Either.left(()), Either.right);
    });
  }

  OptionArrow<(A, Whole), (A, Part)> strong<A>() {
    return OptionArrow.fromRun((tuple) {
      final (a, whole) = tuple;
      final functor = run(whole);
      return functor.rmap((part) => (a, part));
    });
  }

  OptionArrow<Either<A, Whole>, Either<A, Part>> choice<A>() {
    return OptionArrow.fromRun((either) {
      return either.match((a) {
        return id<Either<A, Part>>().run(Either.left(a));
      }, (whole) {
        final functor = run(whole);
        return functor.rmap((part) => Either.right(part));
      });
    });
  }
}
