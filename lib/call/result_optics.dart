import 'package:obmin/a_foundation/types/lens.dart';
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
    put: (whole, part) {
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
    put: (whole, part) {
      return part;
    },
  );
}

Lens<Success<Res, Err>, Res> SuccessToResLens<Res, Err>() {
  return Lens(
    get: (whole) {
      return whole.result;
    },
    put: (whole, part) {
      return Success(part);
    },
  );
}

Lens<Failure<Res, Err>, Err> FailureToErrLens<Res, Err>() {
  return Lens(
    get: (whole) {
      return whole.error;
    },
    put: (whole, part) {
      return Failure(part);
    },
  );
}

Prism<Result<Res, Err>, Res> ResultToResPrism<Res, Err>() {
  return ResultToSuccessPrism<Res, Err>().composeWithLens(SuccessToResLens<Res, Err>());
}

Prism<Result<Res, Err>, Err> ResultToErrPrism<Res, Err>() {
  return ResultToFailurePrism<Res, Err>().composeWithLens(FailureToErrLens<Res, Err>());
}
