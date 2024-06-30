// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/call/result.dart';
import 'package:obmin/optics/iso.dart';
import 'package:obmin/optics/optics_factory.dart';
import 'package:obmin/optics/prism.dart';
import 'package:obmin/types/optional.dart';

extension EitherToLeftPrism on OpticsFactory {
  Prism<Result<Res, Err>, Success<Res, Err>> resultToSuccessPrism<Res, Err>() {
    return Prism(
      get: (whole) {
        switch (whole) {
          case Success<Res, Err>():
            return Some(whole);
          case Failure<Res, Err>():
            return None();
        }
      },
      set: (part) {
        return part;
      },
    );
  }

  Prism<Result<Res, Err>, Failure<Res, Err>> resultToFailurePrism<Res, Err>() {
    return Prism(
      get: (whole) {
        switch (whole) {
          case Failure<Res, Err>():
            return Some(whole);
          case Success<Res, Err>():
            return None();
        }
      },
      set: (part) {
        return part;
      },
    );
  }

  Iso<Success<Res, Err>, Res> successToResIso<Res, Err>() {
    return Iso(
      to: (whole) {
        return whole.result;
      },
      from: Success.new,
    );
  }

  Iso<Failure<Res, Err>, Err> failureToErrIso<Res, Err>() {
    return Iso(
      to: (whole) {
        return whole.error;
      },
      from: Failure.new,
    );
  }
}
