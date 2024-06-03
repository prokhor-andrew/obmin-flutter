// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

final class Writer<T, Loggable> {
  final T value;
  final List<Loggable> logs;

  Writer(
    this.value, {
    this.logs = const [],
  });

  Writer<R, Loggable> map<R>(R Function(T value) function) {
    return Writer(function(value), logs: logs);
  }

  Writer<R, Loggable> bind<R>(Writer<R, Loggable> Function(T value) function) {
    final writer = function(value);
    final newLogs = logs + writer.logs;
    return Writer(writer.value, logs: newLogs);
  }

  @override
  String toString() {
    return "$Writer<$T, $Loggable>{ value=$value _ logs=$logs }";
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Writer<T, Loggable> && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
