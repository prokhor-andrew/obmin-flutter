// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/list.dart';

final class ListArrow<Whole, Part> {
  final Func<Whole, IList<Part>> run;

  const ListArrow(this.run);

  static ListArrow<A, A> id<A>() {
    return ListArrow((value) => [value].lock);
  }

  ListArrow<Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return ListArrow((whole) {
      return run(whole).rmap(f);
    });
  }

  ListArrow<Whole, Sub> compose<Sub>(ListArrow<Part, Sub> other) {
    return ListArrow((whole) {
      return run(whole).bind(other.run);
    });
  }

  ListArrow<Whole, (Part, Part2)> crossJoinZipWith<Part2>(ListArrow<Whole, Part2> other) {
    return ListArrow((whole) {
      return run(whole).crossJoinZipWith(other.run(whole));
    });
  }

  ListArrow<Whole, (Part, Part2)> pointIndexZipWith<Part2>(ListArrow<Whole, Part2> other) {
    return ListArrow((whole) {
      return run(whole).pointIndexZipWith(other.run(whole));
    });
  }
}
