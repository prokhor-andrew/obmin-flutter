// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

extension MinusOnSetExtension<T> on Set<T> {
  Set<T> minus(T value) {
    final copy = toSet();
    copy.remove(value);

    return copy;
  }

  Set<T> minusWhere(bool Function(T value) predicate) {
    final list = toList();

    if (isEmpty) {
      return this;
    }

    int searchIndex = -1;

    for (int i = 0; i < length; i++) {
      if (predicate(list[i])) {
        searchIndex = i;
        break;
      }
    }

    if (searchIndex == -1) {
      return this;
    }

    list.removeAt(searchIndex);

    return list.toSet();
  }
}
