part of 'channel.dart';

final class ChannelBufferData<T> {
  final String id;
  final T data;
  final Completer<bool> _completer;

  ChannelBufferData._({
    required this.id,
    required this.data,
    required Completer<bool> completer,
  }) : _completer = completer;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChannelBufferData<T> && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChannelBufferData<$T>{ id=$id _ data=$data }';
  }
}
