// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'dart:async';

import 'package:obmin/a_foundation/channel/channel.dart';
import 'package:obmin/a_foundation/types/optional.dart';

final class Machine<Input, Output> {
  final ChannelBufferStrategy<Input>? inputBufferStrategy;
  final ChannelBufferStrategy<Output>? outputBufferStrategy;

  final String id;

  final (
    Future<void> Function(void Function(Output output)? callback) onChange,
    Future<void> Function(Input input) onProcess,
  )
      Function() onCreate;

  Machine({
    required this.id,
    this.inputBufferStrategy,
    this.outputBufferStrategy,
    required this.onCreate,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Machine<Input, Output> && runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  Process<Input> run({
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    required Future<void> Function(Output output) onConsume,
  }) {
    final ChannelBufferStrategy<Output> actualOutputBufferStrategy =
        this.outputBufferStrategy ?? outputBufferStrategy ?? ChannelBufferStrategy.defaultStrategy(id: "default");
    final ChannelBufferStrategy<Input> actualInputBufferStrategy =
        this.inputBufferStrategy ?? inputBufferStrategy ?? ChannelBufferStrategy.defaultStrategy(id: "default");

    final Channel<Input> inputChannel = Channel(
      bufferStrategy: actualInputBufferStrategy,
    );

    final Channel<Output> outputChannel = Channel(
      bufferStrategy: actualOutputBufferStrategy,
    );

    bool isCancelled = false;
    ChannelTask<Optional<Input>>? inputTask;
    ChannelTask<Optional<Output>>? outputTask;

    Future<void>(() async {
      if (isCancelled) {
        return;
      }

      final (onChange, onProcess) = onCreate();

      await onChange(outputChannel.send);

      if (!isCancelled) {
        await Future.wait<void>([
          Future<void>(() async {
            while (true) {
              if (isCancelled) {
                break;
              }
              final ChannelTask<Optional<Input>> task = inputChannel.next();
              inputTask = task;
              final value = await task.future;
              if (value is None<Input>) {
                break;
              }
              await onProcess(value.force());
            }
          }),
          Future<void>(() async {
            while (true) {
              if (isCancelled) {
                break;
              }
              final ChannelTask<Optional<Output>> task = outputChannel.next();
              outputTask = task;
              final value = await task.future;
              if (value is None<Output>) {
                break;
              }
              await onConsume(value.force());
            }
          }),
        ]);
      }

      await onChange(null);
    });

    return Process._(
      id: id,
      send: inputChannel.send,
      cancel: () {
        isCancelled = true;
        inputTask?.cancel();
        inputTask = null;
        outputTask?.cancel();
        outputTask = null;
      },
    );
  }
}

final class Process<Input> {
  final String id;
  final void Function(Input) _send;
  final void Function() _cancel;

  Process._({
    required this.id,
    required void Function(Input) send,
    required void Function() cancel,
  })  : _send = send,
        _cancel = cancel;

  void send(Input input) {
    return _send(input);
  }

  void cancel() {
    _cancel();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Process<Input> && runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return "Process<$Input>{ id=$id }";
  }
}
