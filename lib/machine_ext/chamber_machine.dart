// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine/machine_factory.dart';
import 'package:obmin/machine_ext/call_machine.dart';
import 'package:obmin/machine_ext/silo_machine.dart';
import 'package:obmin/machine_ext/feature_machine/feature.dart';
import 'package:obmin/machine_ext/feature_machine/feature_machine.dart';
import 'package:obmin/call/call.dart';
import 'package:obmin/channel/channel_lib.dart';
import 'package:obmin/optics/affine.dart';
import 'package:obmin/types/optional.dart';

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

  Machine<State, Optional<State> Function(State)> chamberX<State, Helper>({
    required String id,
    required Future<Helper> Function() onCreateHelper,
    required Future<void> Function(Helper helper) onDestroyHelper,
    required State initial,
    required Set<Silo<Optional<State> Function(State)>> Function(Helper helper, State state) map,
    ChannelBufferStrategy<State>? inputBufferStrategy,
    ChannelBufferStrategy<Optional<State> Function(State)>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Optional<State> Function(State), State>>? internalBufferStrategy,
  }) {
    return MachineFactory.shared.chamber<State, Optional<State> Function(State), Helper>(
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

  Machine<State, Optional<State> Function(State)> chamberY<State, Helper>({
    required String id,
    required Future<Helper> Function() onCreateHelper,
    required Future<void> Function(Helper helper) onDestroyHelper,
    required State initial,
    required List<ChamberConfig<State>> Function(Helper helper) map,
    ChannelBufferStrategy<State>? inputBufferStrategy,
    ChannelBufferStrategy<Optional<State> Function(State)>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Optional<State> Function(State), State>>? internalBufferStrategy,
  }) {
    return chamberX<State, Helper>(
      id: id,
      onCreateHelper: onCreateHelper,
      onDestroyHelper: onDestroyHelper,
      initial: initial,
      map: (helper, state) {
        final Set<Silo<Optional<State> Function(State)>> result = {};

        for (final config in map(helper)) {
          switch (config._silo(state)) {
            case None<Silo<Optional<State> Function(State)>>():
              break;
            case Some<Silo<Optional<State> Function(State)>>(value: final value):
              result.add(value);
              break;
          }
        }

        return result;
      },
    );
  }
}

final class ChamberConfig<Whole> {
  final Optional<Silo<Optional<Whole> Function(Whole)>> Function(Whole) _silo;

  ChamberConfig._(this._silo);

  static ChamberConfig<Whole> create<Whole, Req, Res>({
    required Affine<Whole, Call<Req, Res>> affine,
    required Silo<Res> Function(Req req) silo,
  }) {
    return ChamberConfig._((state) {
      return MachineFactory.shared.call(
        state: state,
        affine: affine,
        silo: silo,
      );
    });
  }
}
