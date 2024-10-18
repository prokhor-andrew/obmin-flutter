// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:meta/meta.dart';

@immutable
final class Product<L, R> {
  final L left;
  final R right;

  const Product(
    this.left,
    this.right,
  );

  @useResult
  T fold<T>(T Function(L left, R right) function) {
    return function(left, right);
  }

  @useResult
  T combineWith<T, L2, R2>(
    Product<L2, R2> other,
    T Function(L left, R right, L2 left2, R2 right2) function,
  ) {
    return function(left, right, other.left, other.right);
  }

  @useResult
  @override
  String toString() {
    return "Product<$L, $R> { left=$left, right=$right }";
  }

  @useResult
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Product<L, R>) return false;

    return combineWith(
      other,
      (left1, right1, left2, right2) {
        return left1 == left2 && right1 == right2;
      },
    );
  }

  @useResult
  @override
  int get hashCode => left.hashCode ^ right.hashCode;

  @useResult
  Product<T, R> mapLeft<T>(T Function(L value) function) {
    return Product(function(left), right);
  }

  @useResult
  Product<T, R> mapLeftToLazy<T>(T Function() function) {
    return mapLeft((_) => function());
  }

  @useResult
  Product<T, R> mapLeftTo<T>(T value) {
    return mapLeftToLazy(() => value);
  }

  @useResult
  Product<L, T> mapRight<T>(T Function(R value) function) {
    return swapped.mapLeft(function).swapped;
  }

  @useResult
  Product<L, T> mapRightToLazy<T>(T Function() function) {
    return mapRight((_) => function());
  }

  @useResult
  Product<L, T> mapRightTo<T>(T value) {
    return mapRightToLazy(() => value);
  }

  void run(void Function(L left, R right) function) {
    function(left, right);
  }

  void runWith<L2, R2>(
    Product<L2, R2> other,
    void Function(L left, R right, L2 left2, R2 right2) function,
  ) {
    function(left, right, other.left, other.right);
  }

  @useResult
  Product<R, L> get swapped => Product(right, left);
}
