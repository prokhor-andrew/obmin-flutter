// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/lens.dart';
import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/a_foundation/types/prism.dart';

sealed class Result<Res, Err> {
  static Prism<Result<Res, Err>, Success<Res, Err>> successPrism<Res, Err>() {
    return Prism(
      get: (whole) {
        switch (whole) {
          case Success<Res, Err>():
            return Some(whole);
          case Failure<Res, Err>():
            return None();
        }
      },
      put: (whole, part) {
        return part;
      },
    );
  }

  static Prism<Result<Res, Err>, Failure<Res, Err>> failurePrism<Res, Err>() {
    return Prism(
      get: (whole) {
        switch (whole) {
          case Failure<Res, Err>():
            return Some(whole);
          case Success<Res, Err>():
            return None();
        }
      },
      put: (whole, part) {
        return part;
      },
    );
  }
}

final class Success<Res, Err> extends Result<Res, Err> {
  final Res result;

  Success(this.result);

  @override
  String toString() {
    return "Success<$Res, $Err> { result=$result }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Success<Res, Err>) return false;
    return result == other.result;
  }

  @override
  int get hashCode => result.hashCode;

  static Lens<Success<Res, Err>, Res> resultLens<Res, Err>() {
    return Lens(
      get: (whole) {
        return whole.result;
      },
      put: (whole, part) {
        return Success(part);
      },
    );
  }
}

final class Failure<Res, Err> extends Result<Res, Err> {
  final Err error;

  Failure(this.error);

  @override
  String toString() {
    return "Failure<$Res, $Err> { error=$error }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Failure<Res, Err>) return false;
    return error == other.error;
  }

  @override
  int get hashCode => error.hashCode;

  static Lens<Failure<Res, Err>, Err> errorLens<Res, Err>() {
    return Lens(
      get: (whole) {
        return whole.error;
      },
      put: (whole, part) {
        return Failure(part);
      },
    );
  }
}
