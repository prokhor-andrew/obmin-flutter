// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

@immutable
final class Writer<T> {
  final T value;
  final IList<String> logs;

  const Writer(
    this.value, [
    this.logs = const IList.empty(),
  ]);

  @useResult
  @override
  String toString() {
    return "Writer<$T> { value=$value, logs=$logs }";
  }

  @useResult
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Writer<T>) return false;

    return value == other.value && logs == other.logs;
  }

  @override
  int get hashCode => value.hashCode ^ logs.hashCode;

  @useResult
  R fold<R>(R Function(T value, IList<String> logs) function) {
    return function(value, logs);
  }

  @useResult
  R combineWith<R, T2>(
    Writer<T2> other,
    R Function(T value1, IList<String> logs1, T2 value, IList<String> logs2) function,
  ) {
    return fold(
      (value, logs) => other.fold(
        (value2, logs2) => function(value, logs, value2, logs2),
      ),
    );
  }

  @useResult
  Writer<R> map<R>(R Function(T value) function) {
    return Writer(function(value), logs);
  }

  @useResult
  Writer<R> ap<R>(Writer<R Function(T)> other) {
    return Writer(other.value(value), logs.addAll(other.logs));
  }

  @useResult
  Writer<R> bind<R>(Writer<R> Function(T value) function) {
    final result = function(value);
    return Writer(result.value, logs.addAll(result.logs));
  }

  void run(void Function(T value, IList<String> logs) function) {
    fold((value, logs) => () => function(value, logs))();
  }

  void runWith<T2>(
    Writer<T2> other,
    void Function(T value1, IList<String> logs1, T2 value2, IList<String> logs2) function,
  ) {
    combineWith(other, (value1, logs1, value2, logs2) => () => function(value1, logs1, value2, logs2))();
  }
}
