import 'package:obmin_concept/machine.dart';

final class Lens<Whole, Part> {
  final Part Function(Whole whole) get;
  final Whole Function(Whole whole, Part part) put;

  Lens({
    required this.get,
    required this.put,
  });
}

extension LensOutputOnMachine<Input, T, Loggable> on Machine<Input, T Function(T), Loggable> {
  Machine<Input, R Function(R), Loggable> lensOutput<R>(Lens<R, T> lens) {
    return transformOutput((transition) {
      return (whole) {
        final part = lens.get(whole);
        return lens.put(whole, transition(part));
      };
    });
  }
}

extension SetMachineLensOutput<Input, T, Loggable> on Set<Machine<Input, T Function(T), Loggable>> {
  Set<Machine<Input, R Function(R), Loggable>> lensOutput<R>(Lens<R, T> lens) {
    return map((machine) {
      return machine.lensOutput(lens);
    }).toSet();
  }
}
