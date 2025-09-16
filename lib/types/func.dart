// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

typedef Func<A, B> = B Function(A);
typedef BiFunc<A, B, C> = C Function(A, B);

A idfunc<A>(A value) => value;

A absurd<A>(Never v) => v;

Func<A, B> constant<A, B>(B value) {
  return (_) => value;
}
