final class Writer<T, Loggable> {
  final T value;
  final List<Loggable> logs;

  Writer({
    required this.value,
    this.logs = const [],
  });

  Writer<R, Loggable> map<R>(R Function(T value) function) {
    return Writer(value: function(value), logs: logs);
  }

  Writer<R, Loggable> bind<R>(Writer<R, Loggable> Function(T value) function) {
    final writer = function(value);
    final newLogs = logs + writer.logs;
    return Writer(value: writer.value, logs: newLogs);
  }

  @override
  String toString() {
    return "$Writer<$T, $Loggable> value=$value _ logs=$logs";
  }
}
