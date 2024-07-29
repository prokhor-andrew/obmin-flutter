// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

extension FunctionCurryExtension<T1, T2, R> on R Function(T1, T2) {
  R Function(T2) Function(T1) get curried => (t1) {
        return (t2) {
          return this(t1, t2);
        };
      };
}
