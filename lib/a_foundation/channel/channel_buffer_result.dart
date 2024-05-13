part of 'channel.dart';

final class ChannelBufferResult<T, Loggable> {
  final List<ChannelBufferData<T>> data;
  final List<Loggable> logs;

  ChannelBufferResult(
    this.data, {
    this.logs = const [],
  });

  ChannelBufferResult.fromVarArgs(
    this.data, {
    this.logs = const [],
  });

  ChannelBufferResult.fromDataAndVarArgs(
    this.data, {
    this.logs = const [],
  });

  ChannelBufferResult.fromVarArgsAndLogs(
    this.data, {
    this.logs = const [],
  });

  @override
  String toString() {
    return 'ChannelBufferResult<$T, $Loggable> data=$data logs=$logs';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    if (other is! ChannelBufferResult<T, Loggable>) return false;
    return listEquals(other.data, data) && listEquals(other.logs, logs);
  }

  @override
  int get hashCode => data.hashCode ^ logs.hashCode;
}
