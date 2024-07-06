// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/affine.dart';
import 'package:obmin/optics/iso.dart';
import 'package:obmin/optics/optics_factory.dart';
import 'package:obmin/optics/prism.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/optional.dart';

extension EitherOptics on OpticsFactory {
  Prism<Either<L, R>, L> eitherToLeftPrism<L, R>() {
    return Prism(
      get: (whole) {
        return whole.mapRightTo(()).asOptional();
      },
      set: Left.new,
    );
  }

  Prism<Either<L, R>, R> eitherToRightPrism<L, R>() {
    return Prism(
      get: (whole) {
        return whole.mapLeftTo(()).swapped().asOptional();
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

  Iso<Either<L, R>, Either<NL, R>> eitherMapLeftIso<L, R, NL>({
    required NL Function(L value) to,
    required L Function(NL value) from,
  }) {
    return Iso(
      to: (whole) {
        return whole.mapLeft(to);
      },
      from: (part) {
        return part.mapLeft(from);
      },
    );
  }

  Iso<Either<L, R>, Either<L, NR>> eitherMapRightIso<L, R, NR>({
    required NR Function(R value) to,
    required R Function(NR value) from,
  }) {
    return Iso(
      to: (whole) {
        return whole.mapRight(to);
      },
      from: (part) {
        return part.mapRight(from);
      },
    );
  }
}

extension EitherZoom<Whole, L, R> on Affine<Whole, Either<L, R>> {
  Affine<Whole, L> zoomIntoLeft() {
    return then(OpticsFactory.shared.eitherToLeftPrism<L, R>().asAffine());
  }

  Affine<Whole, R> zoomIntoRight() {
    return then(OpticsFactory.shared.eitherToRightPrism<L, R>().asAffine());
  }

  Affine<Whole, Either<R, L>> zoomIntoSwapped() {
    return then(OpticsFactory.shared.eitherSwapIso<L, R>().asAffine());
  }

  Affine<Whole, Either<NL, R>> zoomIntoMapLeft<NL>({
    required NL Function(L value) to,
    required L Function(NL value) from,
  }) {
    return then(OpticsFactory.shared.eitherMapLeftIso<L, R, NL>(to: to, from: from).asAffine());
  }

  Affine<Whole, Either<L, NR>> zoomIntoMapRight<NR>({
    required NR Function(R value) to,
    required R Function(NR value) from,
  }) {
    return then(OpticsFactory.shared.eitherMapRightIso<L, R, NR>(to: to, from: from).asAffine());
  }
}
