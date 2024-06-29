// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

extension CurryingExtension<A, B, R> on R Function(A, B) {
  R Function(B) Function(A) curry() {
    return (A a) {
      return (B b) {
        return this(a, b);
      };
    };
  }

  R Function(B, A) swapArgs() {
    return (B b, A a) {
      return this(a, b);
    };
  }
}
