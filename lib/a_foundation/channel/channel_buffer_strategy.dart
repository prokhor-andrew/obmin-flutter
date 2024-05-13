part of 'channel.dart';

final class ChannelBufferStrategy<T, Loggable> {
  final ChannelBufferResult<T, Loggable> Function(List<ChannelBufferData<T>> data, ChannelBufferEvent event) bufferReducer;

  ChannelBufferStrategy(this.bufferReducer);

  static ChannelBufferStrategy<T, Loggable> defaultStrategy<T, Loggable>() {
    return ChannelBufferStrategy<T, Loggable>((data, event) {
      return ChannelBufferResult<T, Loggable>(data);
    });
  }
}
