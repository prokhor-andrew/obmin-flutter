import 'package:obmin_concept/a_foundation/machine_logger.dart';

final class Machine<Input, Output, Loggable> {
  final String id;

  final (
    Future<void> Function(Future<void> Function(Output output)? callback) onChange,
    Future<void> Function(Input input) onProcess,
  )
      Function(MachineLogger<Loggable> logger) onCreate;

  Machine({
    required this.id,
    required this.onCreate,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Machine<Input, Output, Loggable> && runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  Process<Input, Output, Loggable> run({
    required MachineLogger<Loggable> onLog,
    required Future<void> Function(Output output) onConsume,
  }) {
    final (onChange, onProcess) = this.onCreate(onLog);

    return Process._(
      id: id,
      onChange: onChange,
      onProcess: onProcess,
      onConsume: onConsume,
    );
  }
}

final class Process<Input, Output, Loggable> {
  final String id;

  final _ProcessQueue<Input> _inputQueue;
  final _ProcessQueue<Output> _outputQueue;

  final Future<void> Function(Future<void> Function(Output output)? callback) _onChange;
  final Future<void> Function(Input input) _onProcess;

  Process._({
    required this.id,
    required Future<void> Function(Future<void> Function(Output output)? callback) onChange,
    required Future<void> Function(Input input) onProcess,
    required Future<void> Function(Output output) onConsume,
  })  : _onChange = onChange,
        _onProcess = onProcess,
        _inputQueue = _ProcessQueue(),
        _outputQueue = _ProcessQueue() {
    await onChange((output) {
      this._outputQueue.schedule(() async {
        await onConsume(output);
      });
    });
  }

  Future<void> send(Input input) {
    this._inputQueue.schedule(() async {
      await this._onProcess(input);
    });
  }

  void cancel() {
    this._inputQueue.cancel();
    this._outputQueue.cancel();
    this._onChange(null);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Process<Input, Output, Loggable> && runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

final class _ProcessQueue<T> {
  List<Future<void> Function()> _array = [];
  Future<void>? _executor;

  _ProcessQueue();

  void schedule(Future<void> Function() func) {
    this._array.add(func);

    if (this._executor == null) {
      this._executor = this._execute().whenComplete(() {
        this._executor = null;
      });
    }
  }

  void cancel() {
    this._array = [];
    this._executor = null;
  }

  Future<void> _execute() async {
    while (this._array.isNotEmpty) {
      await this._array[0]();

      if (this._array.isNotEmpty) {
        this._array.removeAt(0);
      }
    }
  }
}
