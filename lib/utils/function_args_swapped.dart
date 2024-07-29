// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

extension FunctionArgsSwappedExtension<T1, T2, R> on R Function(T1, T2) {
  R Function(T2, T1) argsSwapped(T1 t1, T2 t2) {
    return (t2, t1) {
      return this(t1, t2);
    };
  }
}
