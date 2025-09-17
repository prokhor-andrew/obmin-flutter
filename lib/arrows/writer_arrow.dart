// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/func.dart';
import 'package:obmin/types/writer.dart';

final class WriterArrow<E, Whole, Part> {
  final Func<Whole, Writer<E, Part>> run;

  const WriterArrow(this.run);

  static WriterArrow<E, A, A> id<E, A>() {
    return WriterArrow(Writer.of);
  }

  WriterArrow<E, Whole, Sub> compose<Sub>(WriterArrow<E, Part, Sub> other) {
    return WriterArrow((whole) {
      return run(whole).bind(other.run);
    });
  }

  WriterArrow<E, Whole, (Part, Part2)> zipWith<Part2>(WriterArrow<E, Whole, Part2> other) {
    return WriterArrow((whole) {
      return run(whole).zipWith(other.run(whole));
    });
  }
}
