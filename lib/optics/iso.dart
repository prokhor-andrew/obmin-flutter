// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

final class Iso<T1, T2> {
  final T2 Function(T1 value) to;
  final T1 Function(T2 value) from;

  Iso({
    required this.to,
    required this.from,
  });

  static Iso<T, T> identity<T>() {
    return Iso<T, T>(
      to: (v) => v,
      from: (v) => v,
    );
  }

  @override
  String toString() {
    return "Iso<$T1, $T2>";
  }

  Iso<T1, T3> then<T3>(Iso<T2, T3> iso) {
    return Iso(
      to: (t1) {
        return iso.to(to(t1));
      },
      from: (t2) {
        return from(iso.from(t2));
      },
    );
  }
}
