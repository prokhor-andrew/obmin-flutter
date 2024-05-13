Set<Element> uniteSet<Element>(Set<Set<Element>> setOfSets) {
  return setOfSets.fold<Set<Element>>({}, (previousValue, element) => previousValue.union(element));
}
