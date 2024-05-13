import 'package:flutter/material.dart';
import 'package:obmin_concept/a_foundation/machine.dart';
import 'package:obmin_concept/a_foundation/machine_logger.dart';
import 'package:obmin_concept/c_core/core_widget.dart';

class CoreXWidget<DomainState, Loggable> extends StatelessWidget {
  final DomainState Function() state;
  final Set<Machine<DomainState, DomainState Function(DomainState state), Loggable>> Function(DomainState state) machines;
  final List<MachineLogger<Loggable>> Function() loggers;

  final Widget Function(
    BuildContext context,
    DomainState state,
    void Function(DomainState Function(DomainState))? update,
  ) builder;

  const CoreXWidget({
    super.key,
    required this.state,
    required this.machines,
    required this.loggers,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return CoreWidget<DomainState, DomainState Function(DomainState state), Loggable>(
      state: state,
      reducer: (state, trigger) => trigger(state),
      machines: machines,
      loggers: loggers,
      builder: builder,
    );
  }
}
