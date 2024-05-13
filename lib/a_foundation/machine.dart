import 'dart:async';

import 'package:obmin_concept/a_foundation/channel/channel.dart';
import 'package:obmin_concept/a_foundation/machine_logger.dart';

final class Machine<Input, Output, Loggable> {
  final ChannelBufferStrategy<Input, Loggable>? inputBufferStrategy;
  final ChannelBufferStrategy<Output, Loggable>? outputBufferStrategy;

  final String id;

  final (
    Future<void> Function(Future<bool> Function(Output output)? callback) onChange,
    Future<void> Function(Input input) onProcess,
  )
      Function(MachineLogger<Loggable> logger) onCreate;

  Machine({
    required this.id,
    this.inputBufferStrategy,
    this.outputBufferStrategy,
    required this.onCreate,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Machine<Input, Output, Loggable> && runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  Process<Input> run({
    ChannelBufferStrategy<Input, Loggable>? inputBufferStrategy,
    ChannelBufferStrategy<Output, Loggable>? outputBufferStrategy,
    required MachineLogger<Loggable> onLog,
    required Future<void> Function(Output output) onConsume,
  }) {
    final ChannelBufferStrategy<Output, Loggable> actualOutputBufferStrategy =
        this.outputBufferStrategy ?? outputBufferStrategy ?? ChannelBufferStrategy.defaultStrategy();
    final ChannelBufferStrategy<Input, Loggable> actualInputBufferStrategy =
        this.inputBufferStrategy ?? inputBufferStrategy ?? ChannelBufferStrategy.defaultStrategy();

    final Channel<Input, Loggable> inputChannel = Channel(
      bufferStrategy: actualInputBufferStrategy,
      logger: onLog.log,
    );

    final Channel<Output, Loggable> outputChannel = Channel(
      bufferStrategy: actualOutputBufferStrategy,
      logger: onLog.log,
    );

    final Completer<void> completer = Completer();

    throw ""; // TODO:
  }

  Future<void> _task({
    required Channel<Input, Loggable> inputChannel,
    required Channel<Output, Loggable> outputChannel,
    required MachineLogger<Loggable> onLog,
    required Future<void> Function(Output output) onConsume,
  }) async {
    final (onChange, onProcess) = onCreate(onLog);

    await onChange(outputChannel.send);

    await Future.any([
      Future(() async {
        while (true) {
          final value = await inputChannel.next();
          await onProcess(value);
          // TODO: cancel?
          break; // TODO: simulation of cancellation
        }
      }),
      Future(() async {
        while (true) {
          final value = await outputChannel.next();
          await onConsume(value);
          // TODO: cancel?
        }
      }),
    ]);

    await onChange(null);
  }
}

final class Process<Input> {
  final String id;
  final Future<void> Function(Input) _send;
  final void Function() _cancel;

  Process._({
    required this.id,
    required Future<void> Function(Input) send,
    required void Function() cancel,
  })  : _send = send,
        _cancel = cancel;

  Future<void> send(Input input) {
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
}
