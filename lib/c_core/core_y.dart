import 'package:obmin_concept/a_foundation/machine.dart';
import 'package:obmin_concept/a_foundation/machine_logger.dart';
import 'package:obmin_concept/a_foundation/types/writer.dart';
import 'package:obmin_concept/c_core/core.dart';
import 'package:obmin_concept/c_core/core_x.dart';

Core<State, State, Writer<State, Loggable> Function(State state), Loggable> CoreY<State, Loggable>({
  required State Function() state,
  required Set<Machine<State, Writer<State, Loggable> Function(State state), Loggable>> Function(State state) machines,
  required List<MachineLogger<Loggable>> Function() loggers,
}) {
  return CoreX(
    state: state,
    reducer: (state, reducer) {
      return reducer(state);
    },
    machines: machines,
    loggers: loggers,
  );
}
