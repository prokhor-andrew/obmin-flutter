// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/core/core.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine/machine_factory.dart';
import 'package:obmin/machine_ext/basic_machine.dart';

final class CoreWidget<DomainState, Input, Output> extends StatefulWidget {
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

final class _CoreWidgetState<DomainState, Input, Output> extends State<CoreWidget<DomainState, Input, Output>> {
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
        final Machine<Input, Output> uiMachine = widget.uiMachine._machine(() => mounted, (set) {
          setState(() {
            if (mounted) {
              _state = set(_state);
            }
          });
        });

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
  final Object Function(State state) _init;
  final Machine<Input, Output> Function(bool Function() getIsMounted, void Function(Object Function(Object)) setState) _machine;
  final Widget Function(BuildContext context, Object state) _build;

  const WidgetMachine._({
    required Object Function(State state) init,
    required Machine<Input, Output> Function(bool Function() getIsMounted, void Function(Object Function(Object)) setState) machine,
    required Widget Function(BuildContext context, Object state) build,
  })  : _init = init,
        _machine = machine,
        _build = build;

  WidgetMachine<State, RInput, ROutput> transform<RInput, ROutput>(Machine<RInput, ROutput> Function(Machine<Input, Output> machine) function) {
    return WidgetMachine._(
      init: _init,
      build: _build,
      machine: (getIsMounted, setState) {
        return function(_machine(getIsMounted, setState));
      },
    );
  }

  static WidgetMachine<State, Input, Output> create<UiState, State, Input, Output>({
    required String id,
    required UiState Function(State state) init,
    required UiState Function(UiState state, void Function(Output output) callback) activate,
    required UiState Function(UiState state, Input input) process,
    required Widget Function(BuildContext context, UiState state) build,
  }) {
    return WidgetMachine<State, Input, Output>._(
      init: (state) {
        return init(state) as Object;
      },
      machine: (getIsMounted, setState) {
        return MachineFactory.shared.basic<(), Input, Output>(
          id: id,
          onCreate: (id) {
            return ();
          },
          onChange: (_, callback) async {
            if (callback != null) {
              if (getIsMounted()) {
                setState((state) {
                  return activate(state as UiState, (output) async {
                    await callback(output).future;
                  }) as Object;
                });
              }
            }
          },
          onProcess: (_, input) async {
            if (getIsMounted()) {
              setState((state) {
                return process(state as UiState, input) as Object;
              });
            }
          },
        );
      },
      build: (context, state) {
        return build(context, state as UiState);
      },
    );
  }
}
