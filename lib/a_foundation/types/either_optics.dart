// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/either.dart';
import 'package:obmin/a_foundation/types/iso.dart';
import 'package:obmin/a_foundation/types/prism.dart';

Prism<Either<L, R>, L> EitherToLeftPrism<L, R>() {
  return Prism(
    get: (whole) {
      return whole.leftOrNone();
    },
    set: Left.new,
  );
}

Prism<Either<L, R>, R> EitherToRightPrism<L, R>() {
  return Prism(
    get: (whole) {
      return whole.rightOrNone();
    },
    set: Right.new,
  );
}

Iso<Either<L, R>, Either<R, L>> EitherSwapIso<L, R>() {
  return Iso(
    to: (whole) {
      return whole.swapped();
    },
    from: (part) {
      return part.swapped();
    },
  );
}
