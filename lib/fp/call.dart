// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:meta/meta.dart';
import 'package:obmin/fp/optional.dart';
import 'package:obmin/utils/bool_fold.dart';

@immutable
final class Call<Req, Res> {
  final bool _isLaunched;
  final Req? _req;
  final Res? _res;

  const Call.launched(Req req)
      : _req = req,
        _res = null,
        _isLaunched = true;

  const Call.returned(Res res)
      : _res = res,
        _req = null,
        _isLaunched = false;

  @useResult
  T fold<T>(
    T Function(Req req) ifLaunched,
    T Function(Res res) ifReturned,
  ) {
    return _isLaunched.fold<T>(
      () => ifLaunched(_req!),
      () => ifReturned(_res!),
    );
  }

  @useResult
  T combineWith<T, Req2, Res2>(
    Call<Req2, Res2> other, {
    required T Function(Req value, Req2 otherValue) ifLaunchedLaunched,
    required T Function(Req value, Res2 otherValue) ifLaunchedReturned,
    required T Function(Res value, Req2 otherValue) ifReturnedLaunched,
    required T Function(Res value, Res2 otherValue) ifReturnedReturned,
  }) {
    return fold(
      (value) => other.fold(
        (otherValue) => ifLaunchedLaunched(value, otherValue),
        (otherValue) => ifLaunchedReturned(value, otherValue),
      ),
      (value) => other.fold(
        (otherValue) => ifReturnedLaunched(value, otherValue),
        (otherValue) => ifReturnedReturned(value, otherValue),
      ),
    );
  }

  @useResult
  T combineWithOrElseLazy<T, Req2, Res2>(
    Call<Req2, Res2> other, {
    T Function(Req value, Req2 otherValue)? ifLaunchedLaunched,
    T Function(Req value, Res2 otherValue)? ifLaunchedReturned,
    T Function(Res value, Req2 otherValue)? ifReturnedLaunched,
    T Function(Res value, Res2 otherValue)? ifReturnedReturned,
    required T Function() orElse,
  }) {
    return combineWith(
      other,
      ifLaunchedLaunched: ifLaunchedLaunched ?? (_, __) => orElse(),
      ifLaunchedReturned: ifLaunchedReturned ?? (_, __) => orElse(),
      ifReturnedLaunched: ifReturnedLaunched ?? (_, __) => orElse(),
      ifReturnedReturned: ifReturnedReturned ?? (_, __) => orElse(),
    );
  }

  @useResult
  T combineWithOrElse<T, Req2, Res2>(
    Call<Req2, Res2> other, {
    T Function(Req value, Req2 otherValue)? ifLaunchedLaunched,
    T Function(Req value, Res2 otherValue)? ifLaunchedReturned,
    T Function(Res value, Req2 otherValue)? ifReturnedLaunched,
    T Function(Res value, Res2 otherValue)? ifReturnedReturned,
    required T orElse,
  }) {
    return combineWithOrElseLazy(
      other,
      ifLaunchedLaunched: ifLaunchedLaunched,
      ifLaunchedReturned: ifLaunchedReturned,
      ifReturnedLaunched: ifReturnedLaunched,
      ifReturnedReturned: ifReturnedReturned,
      orElse: () => orElse,
    );
  }

  @useResult
  @override
  String toString() {
    return fold<String>(
      (req) => "Call.launched<$Req, $Res> { req=$req }",
      (res) => "Call.returned<$Req, $Res> { res=$res }",
    );
  }

  @useResult
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Call<Req, Res>) return false;

    return combineWith(
      other,
      ifLaunchedLaunched: (req1, req2) => req1 == req2,
      ifLaunchedReturned: (req1, res2) => false,
      ifReturnedLaunched: (res1, req2) => false,
      ifReturnedReturned: (res1, res2) => res1 == res2,
    );
  }

  @useResult
  @override
  int get hashCode => fold(
        (req) => req.hashCode,
        (res) => res.hashCode,
      );

  @useResult
  Call<T, Res> bindLaunched<T>(Call<T, Res> Function(Req req) function) {
    return fold<Call<T, Res>>(
      (value) => function(value),
      Call<T, Res>.returned,
    );
  }

  @useResult
  Call<T, Res> mapLaunched<T>(T Function(Req req) function) {
    return bindLaunched<T>((value) => Call<T, Res>.launched(function(value)));
  }

  @useResult
  Call<T, Res> mapLaunchedToLazy<T>(T Function() function) {
    return mapLaunched((_) => function());
  }

  @useResult
  Call<T, Res> mapLaunchedTo<T>(T value) {
    return mapLaunchedToLazy(() => value);
  }

  @useResult
  Call<Req, T> bindReturned<T>(Call<Req, T> Function(Res res) function) {
    return swapped.bindLaunched((value) => function(value).swapped).swapped;
  }

  @useResult
  Call<Req, T> mapReturned<T>(T Function(Res res) function) {
    return bindReturned<T>((value) => Call<Req, T>.returned(function(value)));
  }

  @useResult
  Call<Req, T> mapReturnedToLazy<T>(T Function() function) {
    return mapReturned((_) => function());
  }

  @useResult
  Call<Req, T> mapReturnedTo<T>(T value) {
    return mapReturnedToLazy<T>(() => value);
  }

  @useResult
  Call<Req2, Res> apLaunched<Req2>(Call<Req2 Function(Req), Res> callWithFunction) {
    return fold(
      (value) => callWithFunction.fold(
        (function) => Call.launched(function(value)),
        Call.returned,
      ),
      Call.returned,
    );
  }

  @useResult
  Call<Req, Res2> apReturned<Res2>(Call<Req, Res2 Function(Res)> callWithFunction) {
    return swapped.apLaunched(callWithFunction.swapped).swapped;
  }

  @useResult
  Call<R, Res> zipWithLaunched<R, Req2>(
    Call<Req2, Res> call,
    R Function(Req req1, Req2 req2) function,
  ) {
    final curried = (Req req1) => (Req2 req2) => function(req1, req2);

    return call.apLaunched(mapLaunched(curried));
  }

  @useResult
  Call<Req, R> zipWithReturned<R, Res2>(
    Call<Req, Res2> call,
    R Function(Res res1, Res2 res2) function,
  ) {
    final curried = (Res res1) => (Res2 res2) => function(res1, res2);

    return call.apReturned(mapReturned(curried));
  }

  void runIfLaunched(void Function(Req value) function) {
    fold<void Function()>(
      (value) => () => function(value),
      (_) => () {},
    )();
  }

  void runIfReturned(void Function(Res value) function) {
    fold<void Function()>(
      (_) => () {},
      (value) => () => function(value),
    )();
  }

  static void _doNothing(a, b) {}

  void runWith<Req2, Res2>(
    Call<Req2, Res2> other, {
    void Function(Req value, Req2 otherValue) ifLaunchedLaunched = _doNothing,
    void Function(Req value, Res2 otherValue) ifLaunchedReturned = _doNothing,
    void Function(Res value, Req2 otherValue) ifReturnedLaunched = _doNothing,
    void Function(Res value, Res2 otherValue) ifReturnedReturned = _doNothing,
  }) {
    combineWith(
      other,
      ifLaunchedLaunched: (value1, value2) => () => ifLaunchedLaunched(value1, value2),
      ifLaunchedReturned: (value1, value2) => () => ifLaunchedReturned(value1, value2),
      ifReturnedLaunched: (value1, value2) => () => ifReturnedLaunched(value1, value2),
      ifReturnedReturned: (value1, value2) => () => ifReturnedReturned(value1, value2),
    )();
  }

  @useResult
  Call<Res, Req> get swapped => fold(
        Call.returned,
        Call.launched,
      );

  @useResult
  Optional<Req> get launchedOrNone => fold<Optional<Req>>(
        Optional.some,
        (res) => const Optional.none(),
      );

  @useResult
  Optional<Res> get returnedOrNone => swapped.launchedOrNone;

  @useResult
  bool get isLaunched => launchedOrNone.isSome;

  @useResult
  bool get isReturned => !isLaunched;
}

extension CallValueWhenBothExtension<T> on Call<T, T> {
  @useResult
  T get value => fold<T>(
        (val) => val,
        (val) => val,
      );
}
