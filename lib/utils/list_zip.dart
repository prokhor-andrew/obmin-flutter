// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'dart:math';

extension ZipListExtension<T1> on List<T1> {
  List<R> zipWith<T2, R>(
    List<T2> list,
    R Function(T1 element1, T2 element2) function,
  ) {
    final size = min(length, list.length);

    final List<R> result = [];

    for (int i = 0; i < size; i++) {
      final element1 = this[i];
      final element2 = list[i];

      result.add(function(element1, element2));
    }

    return result;
  }
}
