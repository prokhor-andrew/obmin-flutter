import 'package:obmin_concept/a_foundation/machine.dart';
import 'package:obmin_concept/a_foundation/machine_factory.dart';
import 'package:obmin_concept/a_foundation/machine_logger.dart';

extension BasicMachine on MachineFactory {
  Machine<Input, Output, Loggable> create<Object, Input, Output, Loggable>({
    required String id,
    required Object Function(String id, MachineLogger<Loggable> logger) onCreate,
    required Future<void> Function(Object object, void Function(Output output)? callback) onChange,
    required Future<void> Function(Object object, Input input) onProcess,
  }) {
    return Machine(
      id: id,
      onCreate: (logger) {
        final object = onCreate(id, logger);

        return (
          (callback) async {
            await onChange(object, callback);
          },
          (input) async {
            await onProcess(object, input);
          },
        );
      },
    );
  }
}
