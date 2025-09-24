// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/arrows/either_arrow.dart';
import 'package:obmin/arrows/list_arrow.dart';
import 'package:obmin/arrows/option_arrow.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/option.dart';

final class GetArrow<Whole, Part> {
  final Func<Whole, Part> run;

  const GetArrow._(this.run);

  static GetArrow<Whole, Part> fromRun<Whole, Part>(Func<Whole, Part> run) {
    return GetArrow._(run);
  }

  static GetArrow<Whole, ()> unit<Whole>() {
    return GetArrow.fromRun(constfunc(()));
  }

  static GetArrow<A, A> id<A>() {
    return GetArrow.fromRun(idfunc);
  }

  GetArrow<Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return GetArrow.fromRun((whole) {
      return f(run(whole));
    });
  }

  GetArrow<Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return GetArrow.fromRun((whole2) {
      return run(f(whole2));
    });
  }

  GetArrow<Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap(lf).rmap(rf);
  }

  GetArrow<Whole, Sub> then<Sub>(GetArrow<Part, Sub> other) {
    return GetArrow.fromRun((whole) {
      return other.run(run(whole));
    });
  }

  GetArrow<Whole2, Part> after<Whole2>(GetArrow<Whole2, Whole> other) {
    return other.then(this);
  }

  GetArrow<Whole, (Part, Part2)> zip<Part2>(GetArrow<Whole, Part2> other) {
    return GetArrow.fromRun((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return (part, part2);
    });
  }

  static GetArrow<Whole, IList<Part>> zipAll<Whole, Part>(IList<GetArrow<Whole, Part>> list) {
    return list.fold(GetArrow.id(), (current, element) {
      final listInOption = element.rmap((value) => [value].lock);
      return current.zip(listInOption).rmap((tuple) => tuple.$1.addAll(tuple.$2));
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
