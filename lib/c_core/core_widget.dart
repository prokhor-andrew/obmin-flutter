// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/a_foundation/machine.dart';
import 'package:obmin/a_foundation/machine_factory.dart';
import 'package:obmin/b_base/basic_machine/basic_machine.dart';
import 'package:obmin/c_core/core.dart';

extension CoreWidgetExtension<State, Input, Output> on Core<State, Input, Output> {
  Widget build<UiState>({
    Key? key,
    required UiState Function(State state) init,
    required UiState Function(UiState state, void Function(Output output) callback) activate,
    required UiState Function(UiState state, Input input) process,
    required Widget Function(BuildContext context, UiState state) build,
  }) {
    return CoreWidget<UiState, State, Input, Output>(
      key: key,
      core: this,
      init: init,
      activate: activate,
      process: process,
      build: build,
    );
  }
}

class CoreWidget<UiState, DomainState, Input, Output> extends StatefulWidget {
  final Core<DomainState, Input, Output> _initialCore;
  final UiState Function(DomainState state) init;
  final UiState Function(UiState state, void Function(Output output) callback) activate;
  final UiState Function(UiState state, Input input) process;
  final Widget Function(BuildContext context, UiState state) build;

  const CoreWidget({
    super.key,
    required Core<DomainState, Input, Output> core,
    required this.init,
    required this.activate,
    required this.process,
    required this.build,
  }) : _initialCore = core;

  @override
  State<CoreWidget<UiState, DomainState, Input, Output>> createState() => _CoreWidgetState<UiState, DomainState, Input, Output>();
}

class _CoreWidgetState<UiState, DomainState, Input, Output> extends State<CoreWidget<UiState, DomainState, Input, Output>> {
  late UiState _state;
  Core<DomainState, Input, Output>? _core;

  @override
  void initState() {
    super.initState();
    final coreScene = widget._initialCore.scene();
    final coreMachines = widget._initialCore.machines(coreScene.state);

    _state = widget.init(coreScene.state);

    final Machine<Input, Output> uiMachine = MachineFactory.shared.create<(), Input, Output>(
      id: "ui_machine",
      onCreate: (id) {
        return ();
      },
      onChange: (_, callback) async {

        if (callback != null) {
          if (mounted) {
            setState(() {
              _state = widget.activate(_state, (output) async {
                await callback(output).future;
              });
            });
          }
        }
      },
      onProcess: (_, input) async {
        if (mounted) {
          setState(() {
            _state = widget.process(_state, input);
          });
        }
      },
    );

    _core = Core<DomainState, Input, Output>(
      scene: () => coreScene,
      machines: (state) => coreMachines.union({uiMachine}),
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
    return widget.build(context, _state);
  }
}
