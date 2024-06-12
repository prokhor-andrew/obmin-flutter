import 'package:obmin/a_foundation/types/either.dart';
import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/a_foundation/types/prism.dart';

Prism<Either<L, R>, L> EitherToLeftPrism<L, R>() {
  return Prism(
    get: (whole) {
      switch (whole) {
        case Left<L, R>(value: final value):
          return Some(value);
        case Right<L, R>():
          return None();
      }
    },
    put: (whole, part) {
      return Left(part);
    },
  );
}

Prism<Either<L, R>, R> EitherToRightPrism<L, R>() {
  return Prism(
    get: (whole) {
      switch (whole) {
        case Left<L, R>():
          return None();
        case Right<L, R>(value: final value):
          return Some(value);
      }
    },
    put: (whole, part) {
      return Right(part);
    },
  );
}
