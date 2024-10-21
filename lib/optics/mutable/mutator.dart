// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:meta/meta.dart';
import 'package:obmin/fp/either.dart';
import 'package:obmin/fp/non_empty_list.dart';
import 'package:obmin/fp/non_empty_map.dart';
import 'package:obmin/fp/non_empty_set.dart';
import 'package:obmin/fp/product.dart';
import 'package:obmin/optics/readonly/fold_list.dart';
import 'package:obmin/optics/readonly/fold_map.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/optics/readonly/update.dart';

@immutable
final class PMutator<S, S1, F, F1> {
  @useResult
  final Getter<Getter<F, F1>, Getter<S, S1>> applier;

  const PMutator(this.applier);

  @useResult
  PMutator<S, S1, SF, SF1> compose<SF, SF1>(PMutator<F, F1, SF, SF1> other) {
    return PMutator(Getter((update) {
      return Getter((whole) {
        return applier.get(Getter((part) {
          return other.applier.get(update).get(part);
        })).get(whole);
      });
    }));
  }

  @useResult
  Getter<S, S1> apply(F1 Function(F part) update) {
    return applier.get(Getter(update));
  }

  @useResult
  Getter<S, S1> set(F1 part) {
    return applier.get(Getter((_) => part));
  }

  @useResult
  @override
  String toString() {
    return "PMutator<$S, $S1, $F, $F1>";
  }

  @useResult
  static Mutator<Whole, Whole> identity<Whole>() {
    return Mutator(Getter((modify) {
      return Getter(modify.get);
    }));
  }

  @useResult
  static PMutator<S, S1, F, F1> pIso<S, S1, F, F1>(
    Getter<S, F> forward,
    Getter<F1, S1> backward,
  ) {
    return PMutator(
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

  @useResult
  static Mutator<Whole, Part> iso<Whole, Part>(
    Getter<Whole, Part> forward,
    Getter<Part, Whole> backward,
  ) {
    return pIso(forward, backward);
  }

  @useResult
  static PMutator<S, S1, F, F1> pPrism<S, S1, F, F1>(
    Getter<S, Either<F, S1>> forward,
    Getter<F1, S1> backward,
  ) {
    return PMutator(
      Getter(
        (update) {
          return Getter(
            (whole) {
              final partOrNone = forward.get(whole);
              final updatedPartOrNone = partOrNone.mapLeft(update.get);
              final result = updatedPartOrNone.mapLeft(backward.get).value;

              return result;
            },
          );
        },
      ),
    );
  }

  @useResult
  static Mutator<Whole, Part> prism<Whole, Part>(
    Preview<Whole, Part> forward,
    Getter<Part, Whole> backward,
  ) {
    return pPrism(Getter((whole) => forward.get(whole).fold(Either.left, () => Either.right(whole))), backward);
  }

  @useResult
  static PMutator<S, S1, F, F1> pLens<S, S1, F, F1>(
    Getter<S, F> get,
    Getter<F1, Getter<S, S1>> reconstruct,
  ) {
    return PMutator(Getter((modify) {
      return Getter((whole) {
        final zoomed = get.get(whole);
        final modified = modify.get(zoomed);
        return reconstruct.get(modified).get(whole);
      });
    }));
  }

  @useResult
  static Mutator<Whole, Part> lens<Whole, Part>(
    Getter<Whole, Part> get,
    Getter<Part, Update<Whole>> reconstruct,
  ) {
    return pLens(get, reconstruct);
  }

  @useResult
  static PMutator<S, S1, F, F1> pAffine<S, S1, F, F1>(
    Getter<S, Either<F, S1>> preview,
    Getter<F1, Getter<S, S1>> reconstruct,
  ) {
    return PMutator(Getter((modify) {
      return Getter((whole) {
        return preview.get(whole).mapLeft(modify.get).mapLeft((part) {
          return reconstruct.get(part).get(whole);
        }).value;
      });
    }));
  }

  @useResult
  static Mutator<Whole, Part> affine<Whole, Part>(
    Preview<Whole, Part> preview,
    Getter<Part, Update<Whole>> reconstruct,
  ) {
    return pAffine(Getter((whole) => preview.get(whole).fold(Either.left, () => Either.right(whole))), reconstruct);
  }

  @useResult
  static Mutator<Whole, Product<int, Part>> traversalList<Whole, Part>(
    FoldList<Whole, Part> fold,
    Getter<NonEmptyList<Part>, Update<Whole>> reconstruct,
  ) {
    return Mutator(Getter((modify) {
      return Getter((whole) {
        final zoomedOrNone = NonEmptySet.fromISet(fold.get(whole));
        return zoomedOrNone.map((zoomed) {
          final modified = zoomed.map(modify.get).fromSetOfProductToList();
          return reconstruct.get(modified).get(whole);
        }).valueOr(whole);
      });
    }));
  }

  @useResult
  static Mutator<Whole, Product<Key, Part>> traversalMap<Whole, Key, Part>(
    FoldMap<Whole, Key, Part> fold,
    Getter<NonEmptyMap<Key, Part>, Update<Whole>> reconstruct,
  ) {
    return Mutator(Getter((modify) {
      return Getter((whole) {
        final zoomedOrNone = NonEmptySet.fromISet(fold.get(whole));
        return zoomedOrNone.map((zoomed) {
          final modified = zoomed.map(modify.get).fromSetOfProductToMap();
          return reconstruct.get(modified).get(whole);
        }).valueOr(whole);
      });
    }));
  }

  @useResult
  static Mutator<Whole, Part> traversalSet<Whole, Part>(
    FoldSet<Whole, Part> fold,
    Getter<NonEmptySet<Part>, Update<Whole>> reconstruct,
  ) {
    return Mutator(Getter((modify) {
      return Getter((whole) {
        final zoomedOrNone = NonEmptySet.fromISet(fold.get(whole));
        return zoomedOrNone.map((zoomed) {
          final modified = zoomed.map(modify.get);
          return reconstruct.get(modified).get(whole);
        }).valueOr(whole);
      });
    }));
  }
}

typedef Mutator<S, F> = PMutator<S, S, F, F>;
