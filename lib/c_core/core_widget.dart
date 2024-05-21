import 'package:flutter/material.dart';
import 'package:obmin_concept/a_foundation/machine.dart';
import 'package:obmin_concept/a_foundation/machine_factory.dart';
import 'package:obmin_concept/b_base/basic_machine/basic_machine.dart';
import 'package:obmin_concept/c_core/core.dart';
import 'package:obmin_concept/utils/list_plus.dart';

extension CoreWidget<State, Input, Output, Loggable> on Core<State, Input, Output, Loggable> {
  Widget build({
    Key? key,
    required Widget Function(
      BuildContext context,
      Input input,
      void Function(Output event)? update,
    ) builder,
  }) {
    return _CoreWidget(
      key: key,
      core: this,
      builder: builder,
    );
  }
}

class _CoreWidget<DomainState, Input, Output, Loggable> extends StatefulWidget {
  final Core<DomainState, Input, Output, Loggable> _initialCore;

  final Widget Function(
    BuildContext context,
    Input input,
    void Function(Output event)? update,
  ) builder;

  const _CoreWidget({
    super.key,
    required Core<DomainState, Input, Output, Loggable> core,
    required this.builder,
  }) : _initialCore = core;

  @override
  State<_CoreWidget<DomainState, Input, Output, Loggable>> createState() => _CoreWidgetState<DomainState, Input, Output, Loggable>();
}

class _CoreWidgetState<DomainState, Input, Output, Loggable> extends State<_CoreWidget<DomainState, Input, Output, Loggable>> {
  Core<DomainState, Input, Output, Loggable>? _core;

  late Input _state;

  void Function(Output event)? _callback;

  @override
  void initState() {
    super.initState();
    Set<Machine<Input, Output, Loggable>> getAllMachines(DomainState state) {
      return widget._initialCore
          .machines(state)
          .toList()
          .plus(
            MachineFactory.shared.create<(), Input, Output, Loggable>(
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
          )
          .toSet();
    }

    _core = Core<DomainState, Input, Output, Loggable>(
      state: widget._initialCore.state,
      reducer: widget._initialCore.reducer,
      machines: getAllMachines,
      loggers: widget._initialCore.loggers,
    );
    _core?.start();
  }

  @override
  void dispose() {
    _core?.stop();
    _core = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state, _callback);
  }
}
