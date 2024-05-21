import 'package:obmin_concept/a_foundation/types/optional.dart';

final class Prism<Whole, Part> {
  final Optional<Part> Function(Whole whole) get;
  final Whole Function(Whole whole, Part part) put;

  Prism({
    required this.get,
    required this.put,
  });
}
