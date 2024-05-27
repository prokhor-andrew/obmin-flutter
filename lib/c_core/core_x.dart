import 'package:obmin_concept/a_foundation/machine.dart';
import 'package:obmin_concept/a_foundation/machine_logger.dart';
import 'package:obmin_concept/a_foundation/types/writer.dart';
import 'package:obmin_concept/c_core/core.dart';

Core<State, State, Event, Loggable> CoreX<State, Event, Loggable>({
  required State Function() state,
  required Writer<State, Loggable> Function(State state, Event event) reducer,
  required Set<Machine<State, Event, Loggable>> Function(State state) machines,
  required Set<MachineLogger<Loggable>> Function() loggers,
}) {
  return Core(
    state: state,
    reducer: (state, trigger) {
      return reducer(state, trigger).map((value) {
        return (
          value,
          [value],
        );
      });
    },
    machines: machines,
    loggers: loggers,
  );
}
