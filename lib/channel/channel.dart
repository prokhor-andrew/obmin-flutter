// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

part of 'channel_lib.dart';

final class Channel<T> {
  _ChannelState<T> _state = _IdleChannelState();

  final ChannelBufferStrategy<T> bufferStrategy;

  Channel({
    required this.bufferStrategy,
  });

  ChannelTask<bool> send(T val) {
    final String id = const Uuid().v4().toString();
    final Completer<bool> completer = Completer();

    switch (_state) {
      case _IdleChannelState<T>():
        _handleBuffer(event: ChannelBufferAddedEvent(), currentArray: [ChannelBufferData._(id: id, data: val, completer: completer)].lock);
        break;
      case _AwaitingForConsumer<T>(buffer: final array):
        _handleBuffer(event: ChannelBufferAddedEvent(), currentArray: array.add(ChannelBufferData._(id: id, data: val, completer: completer)));
        break;
      case _AwaitingForProducer<T>(cur: final cur, rest: final rest):
        _state = _IdleChannelState();
        for (final element in [cur].lock.addAll(rest)) {
          element.comp.complete(Optional<T>.some(val));
        }
        completer.complete(true);
        break;
    }

    return ChannelTask(
      id: id,
      future: completer.future,
      cancel: () {
        switch (_state) {
          case _IdleChannelState<T>() || _AwaitingForProducer<T>():
            break; // do nothing, as there is no completer to be completed
          case _AwaitingForConsumer<T>(buffer: final array):
            final currentArray = array.removeWhere((data) {
              if (data.id != id) {
                return true;
              } else {
                data._completer.complete(false);
                return false;
              }
            });

            _handleBuffer(
              event: ChannelBufferRemovedEvent(isConsumed: false),
              currentArray: currentArray,
            );
        }
      },
    );
  }

  ChannelTask<Optional<T>> next() {
    final String id = const Uuid().v4().toString();
    final Completer<Optional<T>> completer = Completer();

    switch (_state) {
      case _IdleChannelState<T>():
        _state = _AwaitingForProducer(cur: _ChannelConsumer(id, completer), rest: <_ChannelConsumer<T>>[].lock);
        break;
      case _AwaitingForProducer<T>(cur: final cur, rest: final rest):
        _state = _AwaitingForProducer(cur: cur, rest: rest.add(_ChannelConsumer(id, completer)));
        break;
      case _AwaitingForConsumer<T>(buffer: final array):
        array[0]._completer.complete(true);
        completer.complete(Optional<T>.some(array[0].data));

        _handleBuffer(event: ChannelBufferRemovedEvent(isConsumed: true), currentArray: array.removeAt(0));
        break;
    }

    return ChannelTask(
      id: id,
      future: completer.future,
      cancel: () {
        switch (_state) {
          case _IdleChannelState<T>() || _AwaitingForConsumer<T>():
            break; // do nothing as there is no completer to complete
          case _AwaitingForProducer<T>(cur: final cur, rest: final rest):
            if (cur.id == id) {
              if (rest.isEmpty) {
                _state = _IdleChannelState();
                cur.comp.complete(Optional<T>.none());
              } else {
                _state = _AwaitingForProducer(cur: rest[0], rest: rest.removeAt(0));
                cur.comp.complete(Optional<T>.none());
              }
            } else {
              final newList = rest.removeWhere((item) {
                if (item.id != id) {
                  return true;
                } else {
                  item.comp.complete(Optional<T>.none());
                  return false;
                }
              });
              _state = _AwaitingForProducer(
                cur: cur,
                rest: newList,
              );
            }
            break;
        }
      },
    );
  }

  void _handleBuffer({
    required ChannelBufferEvent event,
    required IList<ChannelBufferData<T>> currentArray,
  }) {
    final bufferedArray = bufferStrategy.bufferReducer(currentArray, event);

    final IList<ChannelBufferData<T>> withoutDuplicates =
        bufferedArray.fold<IList<ChannelBufferData<T>>>(<ChannelBufferData<T>>[].lock, (partialResult, element) {
      return partialResult.contains(element) ? partialResult : partialResult.add(element);
    });

    final set1 = currentArray.toISet();
    final set2 = withoutDuplicates.toISet();

    final difference = set1.union(set2).difference(set1.intersection(set2));
    _state = withoutDuplicates.isEmpty ? _IdleChannelState() : _AwaitingForConsumer(withoutDuplicates);

    for (final element in difference) {
      element._completer.complete(false);
    }
  }
}

sealed class _ChannelState<T> {}

final class _IdleChannelState<T> extends _ChannelState<T> {}

final class _AwaitingForProducer<T> extends _ChannelState<T> {
  final _ChannelConsumer<T> cur;
  final IList<_ChannelConsumer<T>> rest;

  _AwaitingForProducer({
    required this.cur,
    required this.rest,
  });
}

final class _AwaitingForConsumer<T> extends _ChannelState<T> {
  final IList<ChannelBufferData<T>> buffer;

  _AwaitingForConsumer(this.buffer);
}

final class _ChannelConsumer<T> {
  final String id;
  final Completer<Optional<T>> comp;

  _ChannelConsumer(this.id, this.comp);
}
