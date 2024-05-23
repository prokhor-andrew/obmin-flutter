import 'package:obmin_concept/a_foundation/machine.dart';
import 'package:obmin_concept/a_foundation/machine_factory.dart';
import 'package:obmin_concept/a_foundation/machine_logger.dart';
import 'package:obmin_concept/a_foundation/types/writer.dart';
import 'package:obmin_concept/b_base/feature_machine/feature_machine.dart';
import 'package:obmin_concept/b_base/feature_machine/scene.dart';

final class Core<State, Input, Output, Loggable> {
  final State Function() state;
  final Writer<(State state, List<Input> effects), Loggable> Function(State state, Output trigger) reducer;
  final Set<Machine<Input, Output, Loggable>> Function(State state) machines;
  final List<MachineLogger<Loggable>> Function() loggers;

  Process<void>? _process;

  Core({
    required this.state,
    required this.reducer,
    required this.machines,
    required this.loggers,
  });

  void start() {
    if (_process != null) {
      return;
    }

    final aState = state();
    final aLoggers = loggers();
    final aMachines = machines(aState);

    _process = MachineFactory.shared
        .feature(
          id: "core",
          feature: (id, logger) {
            Scene<State, Output, Input, Loggable> scene(State state) {
              return Scene.create(
                state: state,
                transit: (payload, trigger, machineId) {
                  return reducer(payload, trigger).map((pair) {
                    return SceneTransition(scene(pair.$1), effects: pair.$2);
                  });
                },
              );
            }

            return scene(aState).asIntTriggerIntEffect().asFeature(aMachines);
          },
        )
        .run(
          onLog: MachineLogger((loggable) {
            for (final logger in aLoggers) {
              logger.log(loggable);
            }
          }),
          onConsume: (_) async {},
        );
  }

  void stop() {
    _process?.cancel();
    _process = null;
  }
}
