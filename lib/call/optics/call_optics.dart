// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/call/call.dart';
import 'package:obmin/optics/affine.dart';
import 'package:obmin/optics/iso.dart';
import 'package:obmin/optics/optics_factory.dart';
import 'package:obmin/optics/prism.dart';
import 'package:obmin/type_optics/either_optics.dart';
import 'package:obmin/types/either.dart';

extension CallOptics on OpticsFactory {
  Iso<Call<Req, Res>, Either<Req, Res>> callToEitherIso<Req, Res>() {
    return Iso(
      to: (value) {
        return value.asEither();
      },
      from: (value) {
        return value.asCall();
      },
    );
  }

  Iso<Either<Req, Res>, Call<Req, Res>> eitherToCallIso<Req, Res>() {
    return Iso(
      to: (value) {
        return value.asCall();
      },
      from: (value) {
        return value.asEither();
      },
    );
  }

  Prism<Call<Req, Res>, Req> callToReqPrism<Req, Res>() {
    return callToEitherIso<Req, Res>().asPrism().then(eitherToLeftPrism<Req, Res>());
  }

  Prism<Call<Req, Res>, Res> callToResPrism<Req, Res>() {
    return callToEitherIso<Req, Res>().asPrism().then(eitherToRightPrism<Req, Res>());
  }
}

extension CallToEitherZoom<Whole, Req, Res> on Affine<Whole, Call<Req, Res>> {
  Affine<Whole, Either<Req, Res>> zoomIntoEither() {
    return then(OpticsFactory.shared.callToEitherIso<Req, Res>().asAffine());
  }
}

extension EitherToCallZoom<Whole, L, R> on Affine<Whole, Either<L, R>> {
  Affine<Whole, Call<L, R>> zoomIntoCall() {
    return then(OpticsFactory.shared.eitherToCallIso<L, R>().asAffine());
  }
}
