// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/arrows/either_arrow.dart';
import 'package:obmin/arrows/list_arrow.dart';
import 'package:obmin/arrows/option_arrow.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/option.dart';

final class GetArrow<Whole, Part> {
  final Func<Whole, Part> run;

  const GetArrow(this.run);

  static GetArrow<A, A> id<A>() {
    return GetArrow(idfunc);
  }

  GetArrow<Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return GetArrow((whole) {
      return f(run(whole));
    });
  }

  GetArrow<Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return GetArrow((whole2) {
      return run(f(whole2));
    });
  }

  GetArrow<Whole, Sub> compose<Sub>(GetArrow<Part, Sub> other) {
    return GetArrow((whole) {
      return other.run(run(whole));
    });
  }

  GetArrow<Whole, (Part, Part2)> zipWith<Part2>(GetArrow<Whole, Part2> other) {
    return GetArrow((whole) {
      final part = run(whole);
      final part2 = other.run(whole);
      return (part, part2);
    });
  }

  OptionArrow<Whole, Part> asOptionArrow() {
    return OptionArrow((whole) {
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
