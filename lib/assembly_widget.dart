import 'package:flutter/material.dart';
import 'package:obmin_concept/machine.dart';
import 'package:obmin_concept/machine_logger.dart';
import 'package:obmin_concept/scene.dart';

class AssemblyWidget<DomainState, Loggable> extends StatefulWidget {
  final DomainState Function() state;
  final Set<Machine<DomainState, DomainState Function(DomainState state), Loggable>> Function(DomainState state) machines;
  final List<MachineLogger<Loggable>> Function() loggers;

  final Widget Function(
    BuildContext context,
    DomainState state,
    void Function(DomainState Function(DomainState state) transition)? setState,
  ) builder;

  const AssemblyWidget({
    super.key,
    required this.state,
    required this.machines,
    required this.loggers,
    required this.builder,
  });

  @override
  State<AssemblyWidget<DomainState, Loggable>> createState() => _AssemblyWidgetState<DomainState, Loggable>();
}

class _AssemblyWidgetState<DomainState, Loggable> extends State<AssemblyWidget<DomainState, Loggable>> {
  Process<void, void, Loggable>? _process;

  late DomainState _state;
  void Function(DomainState Function(DomainState))? _callback;

  @override
  void initState() {
    super.initState();
    final loggers = widget.loggers();
    final domainState = widget.state();
    _state = domainState;

    final machines = widget.machines(domainState);
    machines.add(
      Machine.create<(), DomainState, DomainState Function(DomainState), Loggable>(
        id: "${toString()}_ui",
        onCreate: (id, logger) {
          return ();
        },
        onChange: (_, callback) {
          _callback = callback;
        },
        onProcess: (_, input) async {
          if (mounted) {
            setState(() {
              _state = input;
            });
          }
        },
      ),
    );

    _process = Machine.feature(
      id: "${toString()}_root",
      feature: (machineId, logger) {
        Scene<DomainState, DomainState Function(DomainState), DomainState, Loggable> scene(DomainState state) {
          return Scene.create(
            state: state,
            transit: (extras, trigger) {
              final newState = trigger(extras.state);
              return SceneTransition(scene(newState), effects: [newState]);
            },
          );
        }

        return scene(domainState).asIntTriggerIntEffect<void, void>().asFeature(machines);
      },
    ).run(
      onLog: MachineLogger((loggable) {
        for (final logger in loggers) {
          logger.log(loggable);
        }
      }),
      onConsume: (_) async {},
    );
  }

  @override
  void dispose() {
    _process?.cancel();
    _process = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state, _callback);
  }
}
