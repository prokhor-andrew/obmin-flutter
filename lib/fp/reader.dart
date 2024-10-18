// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:meta/meta.dart';

@immutable
final class Reader<Env, T> {

  @useResult
  final T Function(Env env) run;

  const Reader(this.run);

  @useResult
  Reader<Env, R> map<R>(R Function(T value) function) {
    return Reader((env) => function(run(env)));
  }

  @useResult
  Reader<Env, R> ap<R>(Reader<Env, R Function(T)> other) {
    return Reader((env) => other.run(env)(run(env)));
  }

  @useResult
  Reader<Env, R> bind<R>(Reader<Env, R> Function(T value) function) {
    return Reader((env) => function(run(env)).run(env));
  }
}
