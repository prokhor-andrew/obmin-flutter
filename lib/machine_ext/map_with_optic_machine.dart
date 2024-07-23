// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/channel/channel_lib.dart';
import 'package:obmin/machine_ext/feature_machine/feature.dart';
import 'package:obmin/machine_ext/map_output_machine.dart';
import 'package:obmin/machine_ext/silo_machine.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/types/update.dart';

extension MapWithOpicToUpdateMachineExtension<T> on Silo<Update<T>> {
  Silo<Update<R>> mapWithOpticIntoUpdate<R>(
    Mutator<R, T> mutator, {
    ChannelBufferStrategy<()>? inputBufferStrategy,
    ChannelBufferStrategy<Update<R>>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<Update<T>, ()>>? internalBufferStrategy,
  }) {
    return map<Update<R>>(
      (update) {
        return (whole) {
          return mutator.apply(whole, update);
        };
      },
      internalBufferStrategy: internalBufferStrategy,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
    );
  }
}

extension MapWithOpticMachineExtension<T> on Silo<T> {
  Silo<Update<R>> mapWithOpticIntoSet<R>(
    Mutator<R, T> mutator, {
    ChannelBufferStrategy<()>? inputBufferStrategy,
    ChannelBufferStrategy<Update<R>>? outputBufferStrategy,
    ChannelBufferStrategy<FeatureEvent<T, ()>>? internalBufferStrategy,
  }) {
    return map<Update<R>>(
      (value) {
        return (whole) {
          return mutator.set(whole, value);
        };
      },
      internalBufferStrategy: internalBufferStrategy,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
    );
  }
}
