// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin_concept/a_foundation/types/optional.dart';

final class Prism<Whole, Part> {
  final Optional<Part> Function(Whole whole) get;
  final Whole Function(Whole whole, Part part) put;

  Prism({
    required this.get,
    required this.put,
  });

  @override
  String toString() {
    return "$Prism<$Whole, $Part>";
  }
}
