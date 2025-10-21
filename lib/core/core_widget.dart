// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:obmin/obmin.dart';
import 'package:obmin_flutter/core/core.dart';
import 'package:obmin_flutter/core/value_listenable_ext.dart';
import 'package:obmin_flutter/core/value_notifier_holder.dart';

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

  static CoreWidget<S, S, Event> createX<S, Event>({
    required Core<S, S, Event> core,
    required WidgetMachine<S, S, Event> uiMachine,
  }) {
    return CoreWidget<S, S, Event>(
      core: core,
      uiMachine: uiMachine,
    );
  }

  static CoreWidget<S, S, Endo<S>> createY<S>({
    required Core<S, S, Endo<S>> core,
    required WidgetMachine<S, S, Endo<S>> uiMachine,
  }) {
    return createX<S, Endo<S>>(
      core: core,
      uiMachine: uiMachine,
    );
  }
}

final class _CoreWidgetState<DomainState, Input, Output> extends State<CoreWidget<DomainState, Input, Output>> {
  late ValueNotifier<Object> _notifier;
  Core<DomainState, Input, Output>? _core;

  @override
  void initState() {
    super.initState();
    final coreScene = widget._initialCore.plan();
    final coreMachines = widget._initialCore.machines(coreScene.state);

    _notifier = ValueNotifier(widget.uiMachine._init(coreScene.state));

    _core = Core<DomainState, Input, Output>(
      plan: () {
        return coreScene;
      },
      machines: (state) {
        final Machine<Input, Output> uiMachine = widget.uiMachine._machine((reduce) {
          _notifier.value = reduce(_notifier.value);
        });

        return coreMachines.add("ui_machine", uiMachine);
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
    return widget.uiMachine._build(context, _notifier);
  }
}

final class WidgetMachine<S, Input, Output> {
  final Object Function(S state) _init;
  final Machine<Input, Output> Function(void Function(Object Function(Object)) setState) _machine;
  final Widget Function(BuildContext context, ValueListenable<Object> notifier) _build;

  const WidgetMachine._({
    required Object Function(S state) init,
    required Machine<Input, Output> Function(void Function(Object Function(Object)) setState) machine,
    required Widget Function(BuildContext context, ValueListenable<Object> notifier) build,
  })  : _init = init,
        _machine = machine,
        _build = build;

  WidgetMachine<S, RInput, ROutput> transform<RInput, ROutput>(Machine<RInput, ROutput> Function(Machine<Input, Output> machine) function) {
    return WidgetMachine._(
      init: _init,
      build: _build,
      machine: (setState) {
        return function(_machine(setState));
      },
    );
  }

  static WidgetMachine<S, Input, Output> create<UiState, S, Input, Output>({
    required UiState Function(S state) init,
    required UiState Function(UiState state, void Function(Output output) callback) activate,
    required UiState Function(UiState state, Input input) process,
    required Widget Function(BuildContext context, ValueListenable<UiState> notifier) build,
  }) {
    return WidgetMachine<S, Input, Output>._(
      init: (state) {
        return init(state) as Object;
      },
      machine: (setState) {
        return Machine.fromResource<(), Input, Output>(
          onCreate: () {
            return ();
          },
          onChange: (_, callback) async {
            if (callback != null) {
              setState((state) {
                return activate(state as UiState, (output) async {
                  await callback(output).future;
                }) as Object;
              });
            }
          },
          onProcess: (_, input) async {
            setState((state) {
              return process(state as UiState, input) as Object;
            });
          },
        );
      },
      build: (context, notifier) {
        return build(context, notifier.rmap((value) => value as UiState));
      },
    );
  }

  static WidgetMachine<S, S, Event> widgetMachineX<S, Event>({
    required Widget Function(BuildContext context, ValueListenable<(S state, Option<void Function(Event event)> update)>) builder,
    bool isDistinctUntilChanged = true,
  }) {
    return WidgetMachine.create<(S, Option<void Function(Event event)>), S, S, Event>(
      init: (state) {
        return (state, Option.none());
      },
      activate: (initial, update) {
        return (initial.$1, Option.some(update));
      },
      process: (cur, input) {
        return (input, cur.$2);
      },
      build: (context, notifier) {
        return builder(context, notifier);
      },
    ).transform((machine) {
      return isDistinctUntilChanged ? machine.distinctUntilChangedInput(shouldWaitOnEffects: false) : machine;
    });
  }

  static WidgetMachine<S, S, Endo<S>> _widgetMachineY<S>({
    required Widget Function(BuildContext context, ValueListenable<(S state, Option<void Function(Endo<S> transition)>)> notifier) builder,
    required bool isDistinctUntilChanged,
  }) {
    return widgetMachineX<S, Endo<S>>(
      builder: builder,
      isDistinctUntilChanged: isDistinctUntilChanged,
    );
  }

  static WidgetMachine<S, S, Endo<S>> createY<S>({
    required Widget Function(BuildContext context) builder,
    bool isDistinctUntilChanged = true,
  }) {
    return _widgetMachineY<S>(
      builder: (context, listenable) {
        return ValueNotifierHolder.create<S>(listenable, child: builder(context));
      },
      isDistinctUntilChanged: isDistinctUntilChanged,
    );
  }
}
