// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

sealed class Call<Req, Res> {}

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
}
