// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

extension FutureMapExtension<T> on Future<T> {
  Future<R> map<R>(R Function(T value) function) {
    return then((value) {
      return Future<R>.value(function(value));
    });
  }
}
