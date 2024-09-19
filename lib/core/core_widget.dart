// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'dart:async';

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
  final StreamController<Input> _controller = StreamController.broadcast();

  void Function(Output)? _callback;

  Core<DomainState, Input, Output>? _core;

  @override
  void initState() {
    super.initState();
    final coreScene = widget._initialCore.scene();
    final coreMachines = widget._initialCore.machines(coreScene.state);

    _core = Core<DomainState, Input, Output>(
      scene: () {
        return coreScene;
      },
      machines: (state) {
        final Machine<Input, Output> uiMachine = widget.uiMachine._machine(
          (input) {
            _controller.add(input);
          },
          (callback) {
            _callback = callback;
            if (mounted) {
              setState(() {});
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
    _controller.close();
    _core?.stop();
    _core = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callback = _callback;
    if (callback != null) {
      return widget.uiMachine.started(
        context,
        () => _controller.stream,
        callback,
      );
    } else {
      return widget.uiMachine.stopped(context);
    }
  }
}

final class WidgetMachine<State, Input, Output> {
  final Machine<Input, Output> Function(
    void Function(Input input) sendInput,
    void Function(void Function(Output output)? callback) setCallback,
  ) _machine;

  final Widget Function(BuildContext context) stopped;
  final Widget Function(BuildContext context, Stream<Input> Function() inputs, void Function(Output output) callback) started;

  const WidgetMachine._({
    required this.started,
    required this.stopped,
    required Machine<Input, Output> Function(
      void Function(Input input) sendInput,
      void Function(void Function(Output output)? callback) setCallback,
    ) machine,
  }) : _machine = machine;

  static WidgetMachine<State, Input, Output> create<State, Input, Output>({
    required String id,
    required Widget Function(BuildContext context) stopped,
    required Widget Function(BuildContext context, Stream<Input> Function() inputs, void Function(Output output) callback) started,
  }) {
    return WidgetMachine<State, Input, Output>._(
      started: started,
      stopped: stopped,
      machine: (sendInput, setCallback) {
        return MachineFactory.shared.basic<(), Input, Output>(
          id: id,
          onCreate: (id) {
            return ();
          },
          onChange: (_, callback) async {
            setCallback(callback);
          },
          onProcess: (_, input) async {
            sendInput(input);
          },
        );
      },
    );
  }
}
