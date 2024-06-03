// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

part of 'channel.dart';

final class ChannelTask<T> {
  final String id;
  final Future<T> future;
  final void Function() cancel;

  ChannelTask({
    required this.id,
    required this.future,
    required this.cancel,
  });

  static ChannelTask<List<T>> combine<T>(List<ChannelTask<T>> list) {
    final String id = const Uuid().v4().toString();
    return ChannelTask(
      id: id,
      future: Future.wait(list.map((e) {
        return e.future;
      })),
      cancel: () {
        for (final task in list) {
          task.cancel();
        }
      },
    );
  }

  ChannelTask<R> map<R>(Future<R> Function(Future<T> future) function) {
    return ChannelTask(
      id: id,
      future: function(future),
      cancel: cancel,
    );
  }

  @override
  String toString() {
    return "$ChannelTask<$T> id=$id";
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChannelTask<T> && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
