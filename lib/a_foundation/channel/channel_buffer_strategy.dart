// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

part of 'channel.dart';

final class ChannelBufferStrategy<T, Loggable> {
  final String id;
  final Writer<List<ChannelBufferData<T>>, Loggable> Function(List<ChannelBufferData<T>> data, ChannelBufferEvent event) bufferReducer;

  ChannelBufferStrategy({
    required this.id,
    required this.bufferReducer,
  });

  static ChannelBufferStrategy<T, Loggable> defaultStrategy<T, Loggable>({
    required String id,
  }) {
    return ChannelBufferStrategy<T, Loggable>(
      id: id,
      bufferReducer: (data, event) {
        return Writer<List<ChannelBufferData<T>>, Loggable>(data);
      },
    );
  }

  @override
  String toString() {
    return "ChannelBufferStrategy<$T, $Loggable>{ id=$id }";
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChannelBufferStrategy<T, Loggable> && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
