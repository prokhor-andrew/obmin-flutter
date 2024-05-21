import 'package:flutter/material.dart';
import 'package:obmin_concept/a_foundation/machine.dart';
import 'package:obmin_concept/a_foundation/machine_factory.dart';
import 'package:obmin_concept/a_foundation/machine_logger.dart';
import 'package:obmin_concept/a_foundation/types/writer.dart';
import 'package:obmin_concept/b_base/basic_machine/basic_machine.dart';
import 'package:obmin_concept/b_base/feature_machine/feature_machine.dart';
import 'package:obmin_concept/b_base/feature_machine/scene.dart';

class CoreWidget<DomainState, DomainEvent, Loggable> extends StatefulWidget {
  final DomainState Function() state;
  final Writer<DomainState, Loggable> Function(DomainState state, DomainEvent event) reducer;
  final Set<Machine<DomainState, DomainEvent, Loggable>> Function(DomainState state) machines;
  final List<MachineLogger<Loggable>> Function() loggers;

  final Widget Function(
    BuildContext context,
    DomainState state,
    void Function(DomainEvent event)? update,
  ) builder;

  const CoreWidget({
    super.key,
    required this.state,
    required this.reducer,
    required this.machines,
    required this.loggers,
    required this.builder,
  });

  @override
  State<CoreWidget<DomainState, DomainEvent, Loggable>> createState() => _CoreWidgetState<DomainState, DomainEvent, Loggable>();
}

class _CoreWidgetState<DomainState, DomainEvent, Loggable> extends State<CoreWidget<DomainState, DomainEvent, Loggable>> {
  Process<void>? _process;

  late DomainState _state;
  void Function(DomainEvent event)? _callback;

  @override
  void initState() {
    super.initState();
    final loggers = widget.loggers();
    final domainState = widget.state();
    _state = domainState;

    final machines = widget.machines(domainState);
    machines.add(
      MachineFactory.shared.create<(), DomainState, DomainEvent, Loggable>(
        id: "ui_machine",
        onCreate: (id, logger) {
          return ();
        },
        onChange: (_, callback) async {
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

    _process = MachineFactory.shared
        .feature(
          id: "core",
          feature: (machineId, logger) {
            Scene<DomainState, DomainEvent, DomainState, Loggable> scene(DomainState state) {
              return Scene.create(
                state: state,
                transit: (state, trigger, _) {
                  return widget.reducer(state, trigger).map((newState) {
                    return SceneTransition(
                      scene(newState),
                      effects: [newState],
                    );
                  });
                },
              );
            }

            return scene(domainState).asIntTriggerIntEffect<void, void>().asFeature(machines);
          },
        )
        .run(
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
