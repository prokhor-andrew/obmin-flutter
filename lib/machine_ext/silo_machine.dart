// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine/machine_factory.dart';
import 'package:obmin/machine_ext/basic_machine.dart';
import 'package:obmin/channel/channel_lib.dart';

typedef Silo<T> = Machine<(), T>;

extension SiloMachine on MachineFactory {
  Silo<T> silo<Object, T>({
    required String id,
    required Object Function(void Function(T response) callback) onStart,
    required void Function(Object object) onStop,
    ChannelBufferStrategy<T>? bufferStrategy,
  }) {
    return MachineFactory.shared.basic<_Holder<Object>, (), T>(
      id: id,
      onCreate: (id) {
        return _Holder<Object>();
      },
      onChange: (object, callback) async {
        if (callback != null) {
          object.object = onStart((output) async {
            await callback(output).future;
          });
        } else {
          onStop(object.object as Object);
          object.object = null;
        }
      },
      onProcess: (object, input) async {
        // do nothing
      },
      outputBufferStrategy: bufferStrategy,
    );
  }
}

final class _Holder<Object> {
  Object? object;
}
