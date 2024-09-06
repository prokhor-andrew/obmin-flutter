// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

extension SetOnSetExtension<T> on Set<T> {
  Set<T> plus(T element) {
    final Set<T> copy = toSet();
    copy.add(element);
    return copy;
  }

  Set<T> plusMultiple(Set<T> elements) {
    final Set<T> copy = toSet();
    copy.addAll(elements);
    return copy;
  }
}
