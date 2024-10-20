// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:meta/meta.dart';
import 'package:obmin/fp/optional.dart';
import 'package:obmin/utils/bool_fold.dart';

@immutable
final class Result<Res, Err> {
  final bool _isSuccess;
  final Res? _res;
  final Err? _err;

  const Result.success(Res res)
      : _res = res,
        _err = null,
        _isSuccess = true;

  const Result.failure(Err err)
      : _err = err,
        _res = null,
        _isSuccess = false;

  @useResult
  T fold<T>(
    T Function(Res res) ifSuccess,
    T Function(Err err) ifFailure,
  ) {
    return _isSuccess.fold<T>(
      () => ifSuccess(_res!),
      () => ifFailure(_err!),
    );
  }

  @useResult
  T combineWith<T, Res2, Err2>(
    Result<Res2, Err2> other, {
    required T Function(Res value, Res2 otherValue) ifSuccessSuccess,
    required T Function(Res value, Err2 otherValue) ifSuccessFailure,
    required T Function(Err value, Res2 otherValue) ifFailureSuccess,
    required T Function(Err value, Err2 otherValue) ifFailureFailure,
  }) {
    return fold(
      (value) => other.fold(
        (otherValue) => ifSuccessSuccess(value, otherValue),
        (otherValue) => ifSuccessFailure(value, otherValue),
      ),
      (value) => other.fold(
        (otherValue) => ifFailureSuccess(value, otherValue),
        (otherValue) => ifFailureFailure(value, otherValue),
      ),
    );
  }

  @useResult
  T combineWithOrElseLazy<T, Res2, Err2>(
    Result<Res2, Err2> other, {
    T Function(Res value, Res2 otherValue)? ifSuccessSuccess,
    T Function(Res value, Err2 otherValue)? ifSuccessFailure,
    T Function(Err value, Res2 otherValue)? ifFailureSuccess,
    T Function(Err value, Err2 otherValue)? ifFailureFailure,
    required T Function() orElse,
  }) {
    return combineWith(
      other,
      ifSuccessSuccess: ifSuccessSuccess ?? (_, __) => orElse(),
      ifSuccessFailure: ifSuccessFailure ?? (_, __) => orElse(),
      ifFailureSuccess: ifFailureSuccess ?? (_, __) => orElse(),
      ifFailureFailure: ifFailureFailure ?? (_, __) => orElse(),
    );
  }

  @useResult
  T combineWithOrElse<T, Res2, Err2>(
    Result<Res2, Err2> other, {
    T Function(Res value, Res2 otherValue)? ifSuccessSuccess,
    T Function(Res value, Err2 otherValue)? ifSuccessFailure,
    T Function(Err value, Res2 otherValue)? ifFailureSuccess,
    T Function(Err value, Err2 otherValue)? ifFailureFailure,
    required T orElse,
  }) {
    return combineWithOrElseLazy(
      other,
      ifSuccessSuccess: ifSuccessSuccess,
      ifSuccessFailure: ifSuccessFailure,
      ifFailureSuccess: ifFailureSuccess,
      ifFailureFailure: ifFailureFailure,
      orElse: () => orElse,
    );
  }

  @useResult
  @override
  String toString() {
    return fold<String>(
      (res) => "Result.success<$Res, $Err> { res=$res }",
      (err) => "Result.failure<$Res, $Err> { err=$err }",
    );
  }

  @useResult
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Result<Res, Err>) return false;

    return combineWith(
      other,
      ifSuccessSuccess: (value1, value2) => value1 == value2,
      ifSuccessFailure: (value1, value2) => false,
      ifFailureSuccess: (value1, value2) => false,
      ifFailureFailure: (value1, value2) => value1 == value2,
    );
  }

  @useResult
  @override
  int get hashCode => fold(
        (value) => value.hashCode,
        (value) => value.hashCode,
      );

  @useResult
  Result<T, Err> bindSuccess<T>(Result<T, Err> Function(Res res) function) {
    return fold<Result<T, Err>>(
      (value) => function(value),
      Result<T, Err>.failure,
    );
  }

  @useResult
  Result<T, Err> mapSuccess<T>(T Function(Res res) function) {
    return bindSuccess<T>((value) => Result<T, Err>.success(function(value)));
  }

  @useResult
  Result<T, Err> mapSuccessToLazy<T>(T Function() function) {
    return mapSuccess((_) => function());
  }

  @useResult
  Result<T, Err> mapSuccessTo<T>(T value) {
    return mapSuccessToLazy<T>(() => value);
  }

  @useResult
  Result<Res, T> bindFailure<T>(Result<Res, T> Function(Err err) function) {
    return fold<Result<Res, T>>(
      Result<Res, T>.success,
      (value) => function(value),
    );
  }

  @useResult
  Result<Res, T> mapFailure<T>(T Function(Err err) function) {
    return bindFailure<T>((value) => Result<Res, T>.failure(function(value)));
  }

  @useResult
  Result<Res, T> mapFailureToLazy<T>(T Function() function) {
    return mapFailure((_) => function());
  }

  @useResult
  Result<Res, T> mapFailureTo<T>(T value) {
    return mapFailureToLazy<T>(() => value);
  }

  @useResult
  Result<Res2, Err> apSuccess<Res2>(Result<Res2 Function(Res), Err> resultWithFunction) {
    return fold(
      (value) => resultWithFunction.fold(
        (function) => Result.success(function(value)),
        Result.failure,
      ),
      Result.failure,
    );
  }

  @useResult
  Result<Res, Err2> apFailure<Err2>(Result<Res, Err2 Function(Err)> resultWithFunction) {
    return swapped.apSuccess(resultWithFunction.swapped).swapped;
  }

  @useResult
  Result<R, Err> zipWithSuccess<R, Res2>(
    Result<Res2, Err> other,
    R Function(Res value1, Res2 value2) function,
  ) {
    final curried = (Res val1) => (Res2 val2) => function(val1, val2);

    return other.apSuccess(mapSuccess(curried));
  }

  @useResult
  Result<Res, R> zipWithFailure<R, Err2>(
    Result<Res, Err2> other,
    R Function(Err value1, Err2 value2) function,
  ) {
    return swapped.zipWithSuccess(other.swapped, function).swapped;
  }

  void runIfFailure(void Function(Err value) function) {
    fold<void Function()>(
      (_) => () {},
      (value) => () => function(value),
    )();
  }

  static void _doNothing(dynamic a, dynamic b) {}

  void runWith<Res2, Err2>(
    Result<Res2, Err2> other, {
    void Function(Res value, Res2 otherValue) ifSuccessSuccess = _doNothing,
    void Function(Res value, Err2 otherValue) ifSuccessFailure = _doNothing,
    void Function(Err value, Res2 otherValue) ifFailureSuccess = _doNothing,
    void Function(Err value, Err2 otherValue) ifFailureFailure = _doNothing,
  }) {
    combineWith(
      other,
      ifSuccessSuccess: (value1, value2) => () => ifSuccessSuccess(value1, value2),
      ifSuccessFailure: (value1, value2) => () => ifSuccessFailure(value1, value2),
      ifFailureSuccess: (value1, value2) => () => ifFailureSuccess(value1, value2),
      ifFailureFailure: (value1, value2) => () => ifFailureFailure(value1, value2),
    )();
  }

  @useResult
  Result<Err, Res> get swapped => fold(
        Result.failure,
        Result.success,
      );

  @useResult
  Optional<Res> get successOrNone => fold<Optional<Res>>(
        Optional.some,
        (err) => const Optional.none(),
      );

  @useResult
  Optional<Err> get failureOrNone => swapped.successOrNone;

  @useResult
  bool get isSuccess => successOrNone.isSome;

  @useResult
  bool get isFailure => !isSuccess;
}

extension ResultValueWhenBothExtension<T> on Result<T, T> {
  @useResult
  T get value => fold<T>(
        (val) => val,
        (val) => val,
      );
}
