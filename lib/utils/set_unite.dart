// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

Set<Element> uniteSet<Element>(Set<Set<Element>> setOfSets) {
  return setOfSets.fold<Set<Element>>({}, (previousValue, element) => previousValue.union(element));
}
