// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/lens.dart';
import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/a_foundation/types/prism.dart';
import 'package:obmin/call/call.dart';

Prism<Call<Req, Res>, Launched<Req, Res>> CallToLaunchedPrism<Req, Res>() {
  return Prism(
    get: (whole) {
      switch (whole) {
        case Launched<Req, Res>():
          return Some(whole);
        case Returned<Req, Res>():
          return None();
      }
    },
    put: (whole, part) {
      return part;
    },
  );
}

Prism<Call<Req, Res>, Returned<Req, Res>> CallToReturnedPrism<Req, Res>() {
  return Prism(
    get: (whole) {
      switch (whole) {
        case Launched<Req, Res>():
          return None();
        case Returned<Req, Res>():
          return Some(whole);
      }
    },
    put: (whole, part) {
      return part;
    },
  );
}

Lens<Launched<Req, Res>, Req> LaunchedToReqLens<Req, Res>() {
  return Lens(
    get: (whole) {
      return whole.req;
    },
    put: (whole, part) {
      return Launched(part);
    },
  );
}

Lens<Returned<Req, Res>, Res> ReturnedToResLens<Req, Res>() {
  return Lens(
    get: (whole) {
      return whole.res;
    },
    put: (whole, part) {
      return Returned(part);
    },
  );
}

Prism<Call<Req, Res>, Req> CallToReqPrism<Req, Res>() {
  return CallToLaunchedPrism<Req, Res>().composeWithLens(LaunchedToReqLens<Req, Res>());
}

Prism<Call<Req, Res>, Res> CallToResPrism<Req, Res>() {
  return CallToReturnedPrism<Req, Res>().composeWithLens(ReturnedToResLens<Req, Res>());
}

extension CallPrismExtension<Whole, Req, Res> on Prism<Whole, Call<Req, Res>> {
  Prism<Whole, Req> zoomIntoReq() {
    return composeWithPrism(CallToReqPrism<Req, Res>());
  }

  Prism<Whole, Res> zoomIntoRes() {
    return composeWithPrism(CallToResPrism<Req, Res>());
  }
}

extension CallLensExtension<Whole, Req, Res> on Lens<Whole, Call<Req, Res>> {
  Prism<Whole, Req> zoomIntoReq() {
    return composeWithPrism(CallToReqPrism<Req, Res>());
  }

  Prism<Whole, Res> zoomIntoRes() {
    return composeWithPrism(CallToResPrism<Req, Res>());
  }
}
