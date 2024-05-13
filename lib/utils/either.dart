import 'package:obmin_concept/utils/optional.dart';

sealed class Either<L, R> {
  Either<LeftResult, R> mapLeft<LeftResult>(LeftResult Function(L left) mapper) {
    switch (this) {
      case Left<L, R>(value: var value):
        return Left<LeftResult, R>(mapper(value));
      case Right<L, R>(value: var value):
        return Right<LeftResult, R>(value);
    }
  }

  Either<LeftResult, R> mapLeftTo<LeftResult>(LeftResult value) => mapLeft((_) => value);

  Either<L, RightResult> mapRight<RightResult>(RightResult Function(R right) mapper) {
    switch (this) {
      case Left<L, R>(value: var value):
        return Left<L, RightResult>(value);
      case Right<L, R>(value: var value):
        return Right<L, RightResult>(mapper(value));
    }
  }

  Either<L, RightResult> mapRightTo<RightResult>(RightResult value) => mapRight((_) => value);

  Either<R, L> swapped() {
    switch (this) {
      case Left<L, R>(value: final value):
        return Right(value);
      case Right<L, R>(value: final value):
        return Left(value);
    }
  }

  Optional<L> leftOrNone() {
    switch (this) {
      case Left(value: final value):
        return Some(value);
      case Right():
        return None();
    }
  }

  Optional<R> rightOrNone() {
    switch (this) {
      case Left():
        return None();
      case Right(value: final value):
        return Some(value);
    }
  }

  @override
  String toString() {
    switch (this) {
      case Left<L, R>(value: var value):
        return "Either<$L, $R> left=$value";
      case Right<L, R>(value: var value):
        return "Either<$L, $R> right=$value";
    }
  }

  void executeIfLeft(void Function(L value) function) {
    switch (this) {
      case Left<L, R>(value: final value):
        function(value);
        break;
      case Right<L, R>():
        break;
    }
  }

  void executeIfRight(void Function(R value) function) {
    switch (this) {
      case Left<L, R>():
        break;
      case Right<L, R>(value: final value):
        function(value);
        break;
    }
  }
}

final class Left<L, R> extends Either<L, R> {
  final L value;

  Left(this.value);
}

final class Right<L, R> extends Either<L, R> {
  final R value;

  Right(this.value);
}

extension EitherValue<T> on Either<T, T> {
  T get value => switch (this) {
        Left<T, T>(value: final value) => value,
        Right<T, T>(value: final value) => value,
      };
}

extension OptionalFromEither<T> on Either<None<T>, Some<T>> {
  Optional<T> asOptional() {
    return switch (this) {
      Left<None<T>, Some<T>>(value: final value) => value,
      Right<None<T>, Some<T>>(value: final value) => value,
    };
  }
}
