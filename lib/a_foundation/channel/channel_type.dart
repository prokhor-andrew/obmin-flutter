part of 'channel.dart';


final class Channel<T, Loggable> {
  _ChannelState<T> _state = _IdleChannelState();

  final ChannelBufferStrategy<T, Loggable> bufferStrategy;
  final void Function(Loggable loggable) logger;

  Channel({
    required this.bufferStrategy,
    required this.logger,
  });

  Future<Optional<T>> next() {
    final Completer<Optional<T>> completer = Completer();

    switch (_state) {
      case _IdleChannelState<T>():
        _state = _AwaitingForProducer(cur: ChannelConsumer(completer), rest: []);
        break;
      case _AwaitingForProducer<T>(cur: final cur, rest: final rest):
        _state = _AwaitingForProducer(cur: cur, rest: rest.plus(ChannelConsumer(completer)));
        break;
      case _AwaitingForConsumer<T>(buffer: final array):
        array[0]._completer.complete(true);
        completer.complete(Some(array[0].data));
        _handleBuffer(event: ChannelBufferRemovedEvent(isConsumed: true), currentArray: array.minusFirst());
        break;
    }

    return completer.future;
  }

  Future<bool> yield(T val) {
    final String id = const Uuid().v4().toString();
    final Completer<bool> completer = Completer();

    switch (_state) {
      case _IdleChannelState<T>():
        _handleBuffer(event: ChannelBufferAddedEvent(), currentArray: [ChannelBufferData._(id: id, data: val, completer: completer)]);
        break;
      case _AwaitingForConsumer<T>(buffer: final array):
        _handleBuffer(event: ChannelBufferAddedEvent(), currentArray: array.plus(ChannelBufferData._(id: id, data: val, completer: completer)));
        break;
      case _AwaitingForProducer<T>(cur: final cur, rest: final rest):
        _state = _IdleChannelState();
        [cur].plusMultiple(rest).forEach((element) {
          element.comp.complete(Some(val));
        });
        completer.complete(true);
        break;
    }

    return completer.future;
  }

  void _handleBuffer({
    required ChannelBufferEvent event,
    required List<ChannelBufferData<T>> currentArray,
  }) {
    final bufferedResult = bufferStrategy.bufferReducer(currentArray.toList(), event);

    final bufferedArray = bufferedResult.data.toList();
    final bufferedLogs = bufferedResult.logs.toList();

    final List<ChannelBufferData<T>> withoutDuplicates = bufferedArray.fold<List<ChannelBufferData<T>>>([], (partialResult, element) {
      return partialResult.contains(element) ? partialResult : partialResult.plus(element);
    }).toList();

    final set1 = Set<ChannelBufferData<T>>.from(currentArray);
    final set2 = Set<ChannelBufferData<T>>.from(withoutDuplicates);

    final difference = set1.union(set2).difference(set1.intersection(set2));
    _state = withoutDuplicates.isEmpty ? _IdleChannelState() : _AwaitingForConsumer(withoutDuplicates);

    for (final log in bufferedLogs) {
      logger(log);
    }

    for (final element in difference) {
      element._completer.complete(false);
    }
  }
}

sealed class _ChannelState<T> {}

final class _IdleChannelState<T> extends _ChannelState<T> {}

final class _AwaitingForProducer<T> extends _ChannelState<T> {
  final ChannelConsumer<T> cur;
  final List<ChannelConsumer<T>> rest;

  _AwaitingForProducer({
    required this.cur,
    required this.rest,
  });
}

final class _AwaitingForConsumer<T> extends _ChannelState<T> {
  final List<ChannelBufferData<T>> buffer;

  _AwaitingForConsumer(this.buffer);
}

final class ChannelConsumer<T> {
  final Completer<Optional<T>> comp;

  ChannelConsumer(this.comp);
}
