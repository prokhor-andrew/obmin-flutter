// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/arrows/either_arrow.dart';
import 'package:obmin/arrows/list_arrow.dart';
import 'package:obmin/arrows/option_arrow.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/option.dart';

final class FuncArrow<Whole, Part> {
  final Func<Whole, Part> run;

  const FuncArrow._(this.run);

  static FuncArrow<Whole, Part> fromRun<Whole, Part>(Func<Whole, Part> run) {
    return FuncArrow._(run);
  }

  static FuncArrow<Whole, ()> unit<Whole>() {
    return FuncArrow.fromRun(constfunc(()));
  }

  static FuncArrow<A, A> id<A>() {
    return FuncArrow.fromRun(idfunc);
  }

  FuncArrow<Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return FuncArrow.fromRun((whole) {
      return f(run(whole));
    });
  }

  FuncArrow<Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return FuncArrow.fromRun((whole2) {
      return run(f(whole2));
    });
  }

  FuncArrow<Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap(lf).rmap(rf);
  }

  FuncArrow<Whole, Sub> then<Sub>(FuncArrow<Part, Sub> other) {
    return FuncArrow.fromRun((whole) {
      return other.run(run(whole));
    });
  }

  FuncArrow<Whole2, Part> after<Whole2>(FuncArrow<Whole2, Whole> other) {
    return other.then(this);
  }

  FuncArrow<Whole, (Part, Part2)> zip<Part2>(FuncArrow<Whole, Part2> other) {
    return FuncArrow.fromRun((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return (part, part2);
    });
  }

  static FuncArrow<Whole, IList<Part>> zipAll<Whole, Part>(IList<FuncArrow<Whole, Part>> list) {
    return list.fold(FuncArrow.id(), (current, element) {
      final arrow = element.rmap((value) => [value].lock);
      return current.zip(arrow).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  OptionArrow<Whole, Part> asOptionArrow() {
    return OptionArrow.fromRun((whole) {
      return Option.some(run(whole));
    });
  }

  ListArrow<Whole, Part> asListArrow() {
    return asOptionArrow().asListArrow();
  }

  EitherArrow<(), Whole, Part> asEitherArrow() {
    return asOptionArrow().asEitherArrow();
  }
}
