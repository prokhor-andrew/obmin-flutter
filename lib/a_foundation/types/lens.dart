// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

final class Lens<Whole, Part> {
  final Part Function(Whole whole) get;
  final Whole Function(Whole whole, Part part) put;

  Lens({
    required this.get,
    required this.put,
  });

  @override
  String toString() {
    return "$Lens<$Whole, $Part>";
  }

  Lens<Whole, SubPart> then<SubPart>(Lens<Part, SubPart> lens) {
    return Lens(
      get: (whole) {
        return lens.get(get(whole));
      },
      put: (whole, subPart) {
        return put(whole, lens.put(get(whole), subPart));
      },
    );
  }
}
