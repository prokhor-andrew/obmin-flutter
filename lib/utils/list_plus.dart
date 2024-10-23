// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

extension PlusOnListExtension<T> on List<T> {
  List<T> plus(T element) {
    final List<T> copy = toList();
    copy.add(element);
    return copy;
  }

  List<T> plusMultiple(List<T> elements) {
    final List<T> copy = toList();
    copy.addAll(elements);
    return copy;
  }

  List<T> plusAtStart(T element) {
    final List<T> copy = toList();
    copy.insert(0, element);
    return copy;
  }

  List<T> plusMultipleAtStart(List<T> elements) {
    final List<T> copy = toList();
    copy.insertAll(0, elements);
    return copy;
  }
}
