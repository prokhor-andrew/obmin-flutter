import 'package:obmin_concept/a_foundation/types/either.dart';

sealed class Optional<T> {
  Optional<R> map<R>(R Function(T value) function) {
    return switch (this) {
      None<T>() => None<R>(),
      Some<T>(value: final value) => Some<R>(function(value)),
    };
  }

  Optional<R> bind<R>(Optional<R> Function(T value) function) {
    return switch (this) {
      None<T>() => None<R>(),
      Some<T>(value: final value) => function(value),
    };
  }

  T valueOr(T replacement) {
    return switch (this) {
      None<T>() => replacement,
      Some<T>(value: final value) => value,
    };
  }

  Either<(), T> asEitherNoneLeft() {
    switch (this) {
      case None<T>():
        return Left(());
      case Some<T>(value: final value):
        return Right(value);
    }
  }

  Either<T, ()> asEitherNoneRight() {
    switch (this) {
      case None<T>():
        return Right(());
      case Some<T>(value: final value):
        return Left(value);
    }
  }

  T force() {
    switch (this) {
      case None<T>():
        throw "None<$T> is being forcefully unwrapped";
      case Some<T>(value: final value):
        return value;
    }
  }

  bool test(bool Function(T value) predicate) {
    switch (this) {
      case None<T>():
        return false;
      case Some<T>(value: final value):
        return predicate(value);
    }
  }

  T? valueOrNull() {
    switch (this) {
      case None<T>():
        return null;
      case Some<T>(value: final value):
        return value;
    }
  }

  bool get isNone => switch (this) {
        None<T>() => true,
        Some<T>() => false,
      };

  @override
  String toString() {
    return switch (this) {
      None<T>() => "None<$T>",
      Some<T>(value: final value) => "Some<$T> value=$value",
    };
  }

  void executeIfSome(void Function(T value) function) {
    switch (this) {
      case None<T>():
        break;
      case Some<T>(value: final value):
        function(value);
        break;
    }
  }

  void executeIfNone(void Function() function) {
    switch (this) {
      case None<T>():
        function();
        break;
      case Some<T>():
        break;
    }
  }
}

final class None<T> extends Optional<T> {

  @override
  bool operator ==(Object other) {
    return other is None<T>;
  }

  @override
  int get hashCode => 0;
}

final class Some<T> extends Optional<T> {
  final T value;

  Some(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Some<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
