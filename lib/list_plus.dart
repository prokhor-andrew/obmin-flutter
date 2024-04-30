extension PlusOnList<T> on List<T> {
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
}
