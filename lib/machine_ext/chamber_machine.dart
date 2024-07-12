// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/channel/channel_lib.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine/machine_factory.dart';
import 'package:obmin/machine_ext/feature_machine/feature.dart';
import 'package:obmin/machine_ext/feature_machine/feature_machine.dart';
import 'package:obmin/machine_ext/silo_machine.dart';
import 'package:obmin/types/transition.dart';

extension ChamberMachine on MachineFactory {
  Machine<Input, Output> chamber<Input, Output, Helper>({
    required String id,
    required Future<Helper> Function() onCreateHelper,
    required Future<void> Function(Helper helper) onDestroyHelper,
    required Set<Silo<Output>> Function(Helper helper) initial,
    required Set<Silo<Output>> Function(Helper helper, Input input) map,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Output, Input>>? internalBufferStrategy,
  }) {
    Feature<Helper, Output, (), Input, Output> config(Helper helper, Set<Silo<Output>> machines) {
      return Feature.create(
        state: helper,
        machines: machines,
        transit: (state, machines, trigger, machineId) {
          switch (trigger) {
            case InternalFeatureEvent<Output, Input>(value: final value):
              return FeatureTransition(
                config(state, machines),
                effects: [ExternalFeatureEvent(value)],
              );
            case ExternalFeatureEvent<Output, Input>(value: final value):
              return FeatureTransition(config(state, map(state, value)));
          }
        },
      );
    }

    return MachineFactory.shared.feature(
      id: id,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
      onCreateFeature: () async {
        final helper = await onCreateHelper();
        final initialMachines = initial(helper);
        return config(helper, initialMachines);
      },
      onDestroyFeature: (helper) async {
        await onDestroyHelper(helper);
      },
    );
  }

  Machine<State, Transition<State>> chamberX<State, Helper>({
    required String id,
    required Future<Helper> Function() onCreateHelper,
    required Future<void> Function(Helper helper) onDestroyHelper,
    required State initial,
    required Set<Silo<Transition<State>>> Function(Helper helper, State state) map,
    ChannelBufferStrategy<State>? inputBufferStrategy,
    ChannelBufferStrategy<Transition<State>>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Transition<State>, State>>? internalBufferStrategy,
  }) {
    return MachineFactory.shared.chamber<State, Transition<State>, Helper>(
      id: id,
      onCreateHelper: onCreateHelper,
      onDestroyHelper: onDestroyHelper,
      initial: (helper) {
        return map(helper, initial);
      },
      map: map,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      internalBufferStrategy: internalBufferStrategy,
    );
  }
}
