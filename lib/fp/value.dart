// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:meta/meta.dart';
import 'package:obmin/fp/product.dart';

@immutable
final class Value<State, T> {

  @useResult
  final Product<State, T> Function(State state) run;

  const Value(this.run);

  @useResult
  Value<State, R> map<R>(R Function(T value) function) {
    return Value((state) {
      return run(state).mapRight(function);
    });
  }

  @useResult
  Value<State, R> ap<R>(Value<State, R Function(T)> other) {
    return Value((state) {
      final product = run(state);
      final newState = product.left;
      final result = product.right;

      final product2 = other.run(newState);
      final newState2 = product2.left;
      final result2 = product2.right(result);

      return Product(newState2, result2);
    });
  }

  @useResult
  Value<State, R> bind<R, K>(Value<State, R> Function(T value) function) {
    return Value((state) {
      final stateAndValue = run(state);
      final newState = stateAndValue.left;
      final resultValue = stateAndValue.right;

      final result = function(resultValue);

      return result.run(newState);
    });
  }
}
