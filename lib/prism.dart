import 'package:obmin_concept/machine.dart';
import 'package:obmin_concept/optional.dart';

final class Prism<Whole, Part> {
  final Optional<Part> Function(Whole whole) get;
  final Whole Function(Part part) set;

  Prism({
    required this.get,
    required this.set,
  });
}

extension PrismOutputOnMachine<Input, T, Loggable> on Machine<Input, T Function(T), Loggable> {
  Machine<Input, R Function(R), Loggable> prismOutput<R>(Prism<R, T> prism) {
    return transformOutput((transition) {
      return (whole) {
        return prism.get(whole).map((part) {
          return prism.set(transition(part));
        }).valueOr(whole);
      };
    });
  }
}

extension SetMachinePrismOutput<Input, T, Loggable> on Set<Machine<Input, T Function(T), Loggable>> {
  Set<Machine<Input, R Function(R), Loggable>> prismOutput<R>(Prism<R, T> prism) {
    return map((machine) {
      return machine.prismOutput(prism);
    }).toSet();
  }
}
