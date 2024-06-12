import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/a_foundation/types/prism.dart';

Prism<Optional<T>, T> OptionalToValuePrism<T>() {
  return Prism(
    get: (whole) {
      return whole;
    },
    put: (whole, part) {
      return Some(part);
    },
  );
}
