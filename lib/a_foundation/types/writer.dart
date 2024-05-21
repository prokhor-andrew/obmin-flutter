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
}
