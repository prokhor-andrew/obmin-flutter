// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/either.dart';
import 'package:obmin/a_foundation/types/optics/iso.dart';
import 'package:obmin/a_foundation/types/optics/optics_factory.dart';
import 'package:obmin/a_foundation/types/optics/prism.dart';

extension EitherToLeftPrism on OpticsFactory {
  Prism<Either<L, R>, L> eitherToLeftPrism<L, R>() {
    return Prism(
      get: (whole) {
        return whole.leftOrNone();
      },
      set: Left.new,
    );
  }

  Prism<Either<L, R>, R> eitherToRightPrism<L, R>() {
    return Prism(
      get: (whole) {
        return whole.rightOrNone();
      },
      set: Right.new,
    );
  }

  Iso<Either<L, R>, Either<R, L>> eitherSwapIso<L, R>() {
    return Iso(
      to: (whole) {
        return whole.swapped();
      },
      from: (part) {
        return part.swapped();
      },
    );
  }
}
