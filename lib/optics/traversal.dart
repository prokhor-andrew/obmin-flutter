// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

final class Traversal<Whole, Item> {
  final Iterable<Item> Function(Whole whole) getAll;
  final Whole Function(Whole whole, Item Function(Item item) modify) modifyAll;

  const Traversal({
    required this.getAll,
    required this.modifyAll,
  });

  Traversal<Whole, SubItem> then<SubItem>(Traversal<Item, SubItem> traversal) {
    return Traversal(
      getAll: (whole) {
        return getAll(whole).expand(traversal.getAll);
      },
      modifyAll: (whole, modifySubItem) {
        return modifyAll(
          whole,
          (item) {
            return traversal.modifyAll(item, modifySubItem);
          },
        );
      },
    );
  }

  @override
  String toString() {
    return "Traversal<$Whole, $Item>";
  }
}
