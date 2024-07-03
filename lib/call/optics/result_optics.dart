// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/call/result.dart';
import 'package:obmin/optics/iso.dart';
import 'package:obmin/optics/optics_factory.dart';
import 'package:obmin/optics/prism.dart';
import 'package:obmin/type_optics/either_optics.dart';
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

  Prism<Result<Res, Err>, Res> resultToResPrism<Res, Err>() {
    return resultToEitherIso<Res, Err>().asPrism().then(eitherToLeftPrism<Res, Err>());
  }

  Prism<Result<Res, Err>, Err> resultToErrPrism<Res, Err>() {
    return resultToEitherIso<Res, Err>().asPrism().then(eitherToRightPrism<Res, Err>());
  }
}
