// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

extension FutureMapErrorExtension<T> on Future<T> {
  Future<T> mapError(T Function(dynamic error) function) {
    return catchError((error) {
      return Future<T>.value(function(error));
    });
  }
}
