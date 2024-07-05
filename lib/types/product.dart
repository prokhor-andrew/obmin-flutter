// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

final class Product<T1, T2> {
  final T1 value1;
  final T2 value2;

  Product(this.value1, this.value2);

  R fold<R>(R Function(T1 value1, T2 value2) function) {
    return function(value1, value2);
  }

  Product<T2, T1> swapped() {
    return Product(value2, value1);
  }

  Product<R, T2> mapV1<R>(R Function(T1 value) function) {
    return Product(function(value1), value2);
  }

  Product<R, T2> mapV1To<R>(R value) {
    return mapV1<R>((_) => value);
  }

  Product<T1, R> mapV2<R>(R Function(T2 value) function) {
    return swapped().mapV1(function).swapped();
  }

  Product<T1, R> mapV2To<R>(R value) {
    return mapV2<R>((_) => value);
  }

  @override
  String toString() {
    return "Pair<$T1, $T2> { value1=$value1, value2=$value2 }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product<T1, T2> && other.value1 == value1 && other.value2 == value2;
  }

  @override
  int get hashCode => value1.hashCode ^ value2.hashCode;
}
