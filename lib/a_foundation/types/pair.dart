// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

final class Pair<T1, T2> {
  final T1 v1;
  final T2 v2;

  Pair(this.v1, this.v2);

  @override
  String toString() {
    return "Pair<$T1, $T2> { v1=$v1, v2=$v2 }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pair<T1, T2> && other.v1 == v1 && other.v2 == v2;
  }

  @override
  int get hashCode => v1.hashCode ^ v2.hashCode;

  Pair<T2, T1> swapped() {
    return Pair(v2, v1);
  }
}
