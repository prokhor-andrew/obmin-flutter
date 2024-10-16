// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/fold_list.dart';
import 'package:obmin/optics/readonly/fold_map.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/types/non_empty_list.dart';
import 'package:obmin/types/non_empty_map.dart';
import 'package:obmin/types/non_empty_set.dart';
import 'package:obmin/types/product.dart';
import 'package:obmin/types/update.dart';
import 'package:obmin/utils/as_set.dart';

final class Mutator<Whole, Part> {
  final Getter<Update<Part>, Update<Whole>> applier;

  const Mutator(this.applier);

  Mutator<Whole, Sub> compose<Sub>(Mutator<Part, Sub> other) {
    return Mutator(Getter((update) {
      return Getter((whole) {
        return applier.get(Getter((part) {
          return other.applier.get(update).get(part);
        })).get(whole);
      });
    }));
  }

  Update<Whole> apply(Part Function(Part part) update) {
    return applier.get(Getter(update));
  }

  Update<Whole> set(Part part) {
    return applier.get(Update((_) => part));
  }

  @override
  String toString() {
    return "Mutator<$Whole, $Part>";
  }

  static Mutator<Whole, Whole> identity<Whole>() {
    return Mutator(Getter((modify) {
      return Getter(modify.get);
    }));
  }

  static Mutator<Whole, Part> iso<Whole, Part>(
    Getter<Whole, Part> forward,
    Getter<Part, Whole> backward,
  ) {
    return Mutator(
      Getter(
        (update) {
          return Getter(
            (whole) {
              final part = forward.get(whole);
              final updated = update.get(part);
              final result = backward.get(updated);
              return result;
            },
          );
        },
      ),
    );
  }

  static Mutator<Whole, Part> prism<Whole, Part>(
    Preview<Whole, Part> forward,
    Getter<Part, Whole> backward,
  ) {
    return Mutator(
      Getter(
        (update) {
          return Getter(
            (whole) {
              final partOrNone = forward.get(whole);
              final updatedPartOrNone = partOrNone.map(update.get);
              final result = updatedPartOrNone.map(backward.get).valueOr(whole);

              return result;
            },
          );
        },
      ),
    );
  }

  static Mutator<Whole, Part> biPreview<Whole, Part>(
    Preview<Whole, Part> forward,
    Preview<Part, Whole> backward,
  ) {
    return Mutator(
      Getter(
        (update) {
          return Getter(
            (whole) {
              final partOrNone = forward.get(whole);
              final updatedPartOrNone = partOrNone.map(update.get);
              final wholeOrNone = updatedPartOrNone.bind(backward.get);
              return wholeOrNone.valueOr(whole);
            },
          );
        },
      ),
    );
  }

  static Mutator<Whole, Part> lens<Whole, Part>(
    Getter<Whole, Part> get,
    Getter<Part, Update<Whole>> reconstruct,
  ) {
    return Mutator(Getter((modify) {
      return Getter((whole) {
        final zoomed = get.get(whole);
        final modified = modify.get(zoomed);
        return reconstruct.get(modified).get(whole);
      });
    }));
  }

  static Mutator<Whole, Part> affine<Whole, Part>(
    Preview<Whole, Part> preview,
    Getter<Part, Update<Whole>> reconstruct,
  ) {
    return Mutator(Getter((modify) {
      return Getter((whole) {
        return preview.get(whole).map(modify.get).map((part) {
          return reconstruct.get(part).get(whole);
        }).valueOr(whole);
      });
    }));
  }

  static Mutator<Whole, Product<int, Part>> traversalList<Whole, Part>(
    FoldList<Whole, Part> fold,
    Getter<NonEmptyList<Part>, Update<Whole>> reconstruct,
  ) {
    return Mutator(Getter((modify) {
      return Getter((whole) {
        final zoomedOrNone = NonEmptySet.fromSet(fold.get(whole));
        return zoomedOrNone.map((zoomed) {
          final modified = zoomed.map(modify.get).fromSetOfProductToList();
          return reconstruct.get(modified).get(whole);
        }).valueOr(whole);
      });
    }));
  }

  static Mutator<Whole, Product<Key, Part>> traversalMap<Whole, Key, Part>(
    FoldMap<Whole, Key, Part> fold,
    Getter<NonEmptyMap<Key, Part>, Update<Whole>> reconstruct,
  ) {
    return Mutator(Getter((modify) {
      return Getter((whole) {
        final zoomedOrNone = NonEmptySet.fromSet(fold.get(whole));
        return zoomedOrNone.map((zoomed) {
          final modified = zoomed.map(modify.get).fromSetOfProductToMap();
          return reconstruct.get(modified).get(whole);
        }).valueOr(whole);
      });
    }));
  }

  static Mutator<Whole, Part> traversalSet<Whole, Part>(
    FoldSet<Whole, Part> fold,
    Getter<NonEmptySet<Part>, Update<Whole>> reconstruct,
  ) {
    return Mutator(Getter((modify) {
      return Getter((whole) {
        final zoomedOrNone = NonEmptySet.fromSet(fold.get(whole));
        return zoomedOrNone.map((zoomed) {
          final modified = zoomed.map(modify.get);
          return reconstruct.get(modified).get(whole);
        }).valueOr(whole);
      });
    }));
  }
}
