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
}
