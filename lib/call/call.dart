// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/lens.dart';
import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/a_foundation/types/prism.dart';

sealed class Call<Req, Res> {
  static Prism<Call<Req, Res>, Launched<Req, Res>> launchedPrism<Req, Res>() {
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

  static Prism<Call<Req, Res>, Returned<Req, Res>> returnedPrism<Req, Res>() {
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
}

final class Launched<Req, Res> extends Call<Req, Res> {
  final Req req;

  Launched(this.req);

  @override
  String toString() {
    return "Launched<$Req, $Res> { req=$req }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Launched<Req, Res>) return false;
    return req == other.req;
  }

  @override
  int get hashCode => req.hashCode;

  static Lens<Launched<Req, Res>, Req> zoomInReq<Req, Res>() {
    return Lens(
      get: (whole) {
        return whole.req;
      },
      put: (whole, part) {
        return Launched(part);
      },
    );
  }
}

final class Returned<Req, Res> extends Call<Req, Res> {
  final Res res;

  Returned(this.res);

  @override
  String toString() {
    return "Returned<$Req,  $Res> { res=$res }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Returned<Req, Res>) return false;
    return res == other.res;
  }

  @override
  int get hashCode => res.hashCode;

  static Lens<Returned<Req, Res>, Res> zoomInRes<Req, Res>() {
    return Lens(
      get: (whole) {
        return whole.res;
      },
      put: (whole, part) {
        return Returned(part);
      },
    );
  }
}
