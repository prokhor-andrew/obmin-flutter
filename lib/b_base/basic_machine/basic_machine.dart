// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/channel/channel.dart';
import 'package:obmin/a_foundation/machine.dart';
import 'package:obmin/a_foundation/machine_factory.dart';

extension BasicMachine on MachineFactory {
  Machine<Input, Output> create<Object, Input, Output>({
    required String id,
    required Object Function(String id) onCreate,
    required Future<void> Function(Object object, ChannelTask<bool> Function(Output output)? callback) onChange,
    required Future<void> Function(Object object, Input input) onProcess,
    ChannelBufferStrategy<Input>? inputBufferStrategy,
    ChannelBufferStrategy<Output>? outputBufferStrategy,
  }) {
    return Machine<Input, Output>(
      id: id,
      inputBufferStrategy: inputBufferStrategy,
      outputBufferStrategy: outputBufferStrategy,
      onCreate: () {
        final Object object = onCreate(id);

        return (
          (callback) async {
            await onChange(object, callback);
          },
          (input) async {
            await onProcess(object, input);
          },
        );
      },
    );
  }
}
