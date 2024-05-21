part of 'channel.dart';

final class ChannelBufferStrategy<T, Loggable> {
  final Writer<List<ChannelBufferData<T>>, Loggable> Function(List<ChannelBufferData<T>> data, ChannelBufferEvent event) bufferReducer;

  ChannelBufferStrategy(this.bufferReducer);

  static ChannelBufferStrategy<T, Loggable> defaultStrategy<T, Loggable>() {
    return ChannelBufferStrategy<T, Loggable>((data, event) {
      return Writer<List<ChannelBufferData<T>>, Loggable>(value: data);
    });
  }
}
