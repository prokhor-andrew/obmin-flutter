// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/iso.dart';
import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/a_foundation/types/prism.dart';
import 'package:obmin/call/result.dart';

Prism<Result<Res, Err>, Success<Res, Err>> ResultToSuccessPrism<Res, Err>() {
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

Prism<Result<Res, Err>, Failure<Res, Err>> ResultToFailurePrism<Res, Err>() {
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

Iso<Success<Res, Err>, Res> SuccessToResIso<Res, Err>() {
  return Iso(
    to: (whole) {
      return whole.result;
    },
    from: Success.new,
  );
}

Iso<Failure<Res, Err>, Err> FailureToErrIso<Res, Err>() {
  return Iso(
    to: (whole) {
      return whole.error;
    },
    from: Failure.new,
  );
}
