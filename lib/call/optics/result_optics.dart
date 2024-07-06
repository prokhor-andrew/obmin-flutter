// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/call/result.dart';
import 'package:obmin/optics/affine.dart';
import 'package:obmin/optics/iso.dart';
import 'package:obmin/optics/optics_factory.dart';
import 'package:obmin/types/either.dart';

extension ResultOptics on OpticsFactory {
  Iso<Result<Res, Err>, Either<Res, Err>> resultToEitherIso<Res, Err>() {
    return Iso(
      to: (value) {
        return value.asEither();
      },
      from: (value) {
        return value.asResult();
      },
    );
  }

  Iso<Either<Res, Err>, Result<Res, Err>> eitherToResultIso<Res, Err>() {
    return Iso(
      to: (value) {
        return value.asResult();
      },
      from: (value) {
        return value.asEither();
      },
    );
  }
}

extension ResultToEitherZoom<Whole, Res, Err> on Affine<Whole, Result<Res, Err>> {
  Affine<Whole, Either<Res, Err>> zoomIntoEither() {
    return then(OpticsFactory.shared.resultToEitherIso<Res, Err>().asAffine());
  }
}

extension EitherToResultZoom<Whole, L, R> on Affine<Whole, Either<L, R>> {
  Affine<Whole, Result<L, R>> zoomIntoResult() {
    return then(OpticsFactory.shared.eitherToResultIso<L, R>().asAffine());
  }
}
