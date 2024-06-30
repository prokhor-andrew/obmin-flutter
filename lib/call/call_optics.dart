// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/optics/iso.dart';
import 'package:obmin/a_foundation/types/optics/optics_factory.dart';
import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/a_foundation/types/optics/prism.dart';
import 'package:obmin/call/call.dart';

extension EitherToLeftPrism on OpticsFactory {
  Prism<Call<Req, Res>, Launched<Req, Res>> callToLaunchedPrism<Req, Res>() {
    return Prism(
      get: (whole) {
        switch (whole) {
          case Launched<Req, Res>():
            return Some(whole);
          case Returned<Req, Res>():
            return None();
        }
      },
      set: (part) {
        return part;
      },
    );
  }

  Prism<Call<Req, Res>, Returned<Req, Res>> callToReturnedPrism<Req, Res>() {
    return Prism(
      get: (whole) {
        switch (whole) {
          case Launched<Req, Res>():
            return None();
          case Returned<Req, Res>():
            return Some(whole);
        }
      },
      set: (part) {
        return part;
      },
    );
  }

  Iso<Launched<Req, Res>, Req> launchedToReqIso<Req, Res>() {
    return Iso(
      to: (whole) {
        return whole.req;
      },
      from: Launched.new,
    );
  }

  Iso<Returned<Req, Res>, Res> returnedToResIso<Req, Res>() {
    return Iso(
      to: (whole) {
        return whole.res;
      },
      from: Returned.new,
    );
  }
}
