// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

sealed class Call<Req, Err, Res> {}

final class Launched<Req, Err, Res> extends Call<Req, Err, Res> {
  final Req req;

  Launched(this.req);

  @override
  String toString() {
    return "Launched<$Req, $Err, $Res> { req=$req }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Launched<Req, Err, Res>) return false;
    return req == other.req;
  }

  @override
  int get hashCode => req.hashCode;
}

final class Failure<Req, Err, Res> extends Call<Req, Err, Res> {
  final Err err;

  Failure(this.err);

  @override
  String toString() {
    return "Failure<$Req, $Err, $Res> { err=$err }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Failure<Req, Err, Res>) return false;
    return err == other.err;
  }

  @override
  int get hashCode => err.hashCode;
}

final class Success<Req, Err, Res> extends Call<Req, Err, Res> {
  final Res res;

  Success(this.res);

  @override
  String toString() {
    return "Success<$Req, $Err, $Res> { res=$res }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Success<Req, Err, Res>) return false;
    return res == other.res;
  }

  @override
  int get hashCode => res.hashCode;
}
