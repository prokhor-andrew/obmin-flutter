// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/core/core.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine/machine_factory.dart';
import 'package:obmin/machine_ext/basic_machine.dart';

class CoreWidget<DomainState, Input, Output> extends StatefulWidget {
  final Core<DomainState, Input, Output> _initialCore;
  final WidgetMachine<DomainState, Input, Output> uiMachine;

  const CoreWidget({
    super.key,
    required Core<DomainState, Input, Output> core,
    required this.uiMachine,
  }) : _initialCore = core;

  @override
  State<CoreWidget<DomainState, Input, Output>> createState() => _CoreWidgetState<DomainState, Input, Output>();
}

class _CoreWidgetState<DomainState, Input, Output> extends State<CoreWidget<DomainState, Input, Output>> {
  late Object _state;
  Core<DomainState, Input, Output>? _core;

  @override
  void initState() {
    super.initState();
    final coreScene = widget._initialCore.scene();
    final coreMachines = widget._initialCore.machines(coreScene.state);

    _state = widget.uiMachine._init(coreScene.state);

    _core = Core<DomainState, Input, Output>(
      scene: () {
        return coreScene;
      },
      machines: (state) {
        final Machine<Input, Output> uiMachine = MachineFactory.shared.basic<(), Input, Output>(
          id: widget.uiMachine._id,
          onCreate: (id) {
            return ();
          },
          onChange: (_, callback) async {
            if (callback != null) {
              if (mounted) {
                setState(() {
                  _state = widget.uiMachine._activate(_state, (output) async {
                    await callback(output).future;
                  });
                });
              }
            }
          },
          onProcess: (_, input) async {
            if (mounted) {
              setState(() {
                _state = widget.uiMachine._process(_state, input);
              });
            }
          },
        );

        return coreMachines.union({
          uiMachine,
        });
      },
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
    return widget.uiMachine._build(context, _state);
  }
}

final class WidgetMachine<State, Input, Output> {
  final String _id;
  final Object Function(State state) _init;
  final Object Function(Object state, void Function(Output output) callback) _activate;
  final Object Function(Object state, Input input) _process;
  final Widget Function(BuildContext context, Object state) _build;

  WidgetMachine._({
    required String id,
    required Object Function(State state) init,
    required Object Function(Object state, void Function(Output output) callback) activate,
    required Object Function(Object state, Input input) process,
    required Widget Function(BuildContext context, Object state) build,
  })  : _id = id,
        _init = init,
        _activate = activate,
        _process = process,
        _build = build;

  static WidgetMachine<State, Input, Output> create<UiState, State, Input, Output>({
    required String id,
    required UiState Function(State state) init,
    required UiState Function(UiState state, void Function(Output output) callback) activate,
    required UiState Function(UiState state, Input input) process,
    required Widget Function(BuildContext context, UiState state) build,
  }) {
    return WidgetMachine<State, Input, Output>._(
      id: id,
      init: (state) {
        return init(state) as Object;
      },
      activate: (state, callback) {
        return activate(state as UiState, callback) as Object;
      },
      process: (state, input) {
        return process(state as UiState, input) as Object;
      },
      build: (context, state) {
        return build(context, state as UiState);
      },
    );
  }
}
