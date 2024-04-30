extension MinusOnList<T> on List<T> {
  List<T> minusLast([int count = 1]) {
    assert(count >= 0);

    if (isEmpty || count == 0) {
      return this;
    }

    if (length <= count) {
      return [];
    }

    final List<T> copy = toList();
    for (int i = 0; i < count; i++) {
      copy.removeLast();
    }
    return copy;
  }

  List<T> minusFirst([int count = 1]) {
    assert(count >= 0);

    if (isEmpty || count == 0) {
      return this;
    }

    if (length <= count) {
      return [];
    }

    final List<T> copy = toList();
    for (int i = 0; i < count; i++) {
      copy.removeAt(0);
    }
    return copy;
  }

  List<T> minusWhere(bool Function(T value) predicate) {
    if (isEmpty) {
      return this;
    }

    int searchIndex = -1;

    for (int i = 0; i < length; i++) {
      if (predicate(this[i])) {
        searchIndex = i;
        break;
      }
    }

    if (searchIndex == -1) {
      return this;
    }

    final copy = toList();
    copy.removeAt(searchIndex);

    return copy;
  }
}
