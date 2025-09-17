// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/arrows/either_arrow.dart';
import 'package:obmin/arrows/list_arrow.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/option.dart';

final class OptionArrow<Whole, Part> {
  final Func<Whole, Option<Part>> run;

  const OptionArrow(this.run);

  static OptionArrow<A, A> id<E, A>() {
    return OptionArrow(Option.some);
  }

  OptionArrow<Whole, Sub> compose<Sub>(OptionArrow<Part, Sub> other) {
    return OptionArrow((whole) {
      return run(whole).bind(other.run);
    });
  }

  OptionArrow<Whole, (Part, Part2)> zipWith<Part2>(OptionArrow<Whole, Part2> other) {
    return OptionArrow((whole) {
      return run(whole).zipWith(other.run(whole));
    });
  }

  ListArrow<Whole, Part> asListArrow() {
    return ListArrow((whole) {
      return run(whole).match(IList.empty, (value) => [value].lock);
    });
  }

  EitherArrow<(), Whole, Part> asEitherArrow() {
    return EitherArrow((whole) {
      return run(whole).match(() => Either.left(()), Either.right);
    });
  }
}
