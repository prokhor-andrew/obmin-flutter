// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/either.dart';
import 'package:obmin/types/optional.dart';
import 'package:obmin/types/product.dart';

sealed class Call<Req, Res> {
  Either<Req, Res> asEither() {
    switch (this) {
      case Launched<Req, Res>(value: final value):
        return Left(value);
      case Returned<Req, Res>(value: final value):
        return Right(value);
    }
  }

  Call<Product<Req, void Function(Optional<Req> Function(Req))>, Product<Res, void Function(Optional<Res> Function(Res))>> attachUpdate(
    void Function(Optional<Call<Req, Res>> Function(Call<Req, Res> value) transition) update,
  ) {
    switch (this) {
      case Launched<Req, Res>(value: final value):
        return Launched(
          Product(
            value,
            (transition) {
              update((call) {
                switch (call) {
                  case Launched<Req, Res>(value: final value):
                    return transition(value).map(Launched.new);
                  case Returned<Req, Res>(value: final value):
                    return Some(Returned(value));
                }
              });
            },
          ),
        );
      case Returned<Req, Res>(value: final value):
        return Returned(
          Product(
            value,
            (transition) {
              update((call) {
                switch (call) {
                  case Launched<Req, Res>(value: final value):
                    return Some(Launched(value));
                  case Returned<Req, Res>(value: final value):
                    return transition(value).map(Returned.new);
                }
              });
            },
          ),
        );
    }
  }

  @override
  String toString() {
    switch (this) {
      case Launched<Req, Res>(value: var value):
        return "$Launched<$Req, $Res> { value=$value }";
      case Returned<Req, Res>(value: var value):
        return "$Returned<$Req, $Res> { value=$value }";
    }
  }
}

final class Launched<Req, Res> extends Call<Req, Res> {
  final Req value;

  Launched(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Launched<Req, Res> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

final class Returned<Req, Res> extends Call<Req, Res> {
  final Res value;

  Returned(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Returned<Req, Res> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

extension EitherToCall<Req, Res> on Either<Req, Res> {
  Call<Req, Res> asCall() {
    return fold<Call<Req, Res>>(
      Launched.new,
      Returned.new,
    );
  }
}
