import 'package:obmin_concept/a_foundation/machine.dart';
import 'package:obmin_concept/a_foundation/machine_factory.dart';
import 'package:obmin_concept/b_base/basic_machine/basic_machine.dart';

typedef Silo<T, Loggable> = Machine<(), T Function(T), Loggable>;

extension SiloMachine on MachineFactory {
  Silo<T, Loggable> silo<Object, T, Loggable>({
    required String id,
    required Object Function(void Function(T Function(T) transition) callback) onStart,
    required void Function(Object object) onStop,
  }) {
    return MachineFactory.shared.create(
      id: id,
      onCreate: (id, logger) {
        return _Holder<Object>();
      },
      onChange: (object, callback) async {
        if (callback != null) {
          object.object = onStart(callback);
        } else {
          onStop(object.object as Object);
          object.object = null;
        }
      },
      onProcess: (object, input) async {
        // do nothing
      },
    );
  }
}

final class _Holder<Object> {
  Object? object;
}