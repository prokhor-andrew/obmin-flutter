// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_list.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/optics/transformers/bi_eqv.dart';
import 'package:obmin/optics/transformers/bi_preview.dart';
import 'package:obmin/optics/transformers/iso.dart';
import 'package:obmin/optics/transformers/prism.dart';
import 'package:obmin/optics/transformers/reflector.dart';
import 'package:obmin/types/optional.dart';

extension MapOpticsEqvExtension<Key, T> on Eqv<Map<Key, T>> {
  Preview<Map<Key, T>, T> at(Key key) {
    return asGetter().at(key);
  }

  FoldSet<Map<Key, T>, MapEntry<Key, T>> get folded => asGetter().folded;
}

extension MapOpticsGetterExtension<Whole, Key, T> on Getter<Whole, Map<Key, T>> {
  Preview<Whole, T> at(Key key) {
    return asPreview().at(key);
  }

  FoldSet<Whole, MapEntry<Key, T>> get folded => asPreview().folded;
}

extension MapOpticsPreviewExtension<Whole, Key, T> on Preview<Whole, Map<Key, T>> {
  Preview<Whole, T> at(Key key) {
    return compose(
      Preview<Map<Key, T>, T>(
        (whole) {
          final element = whole[key];
          if (element == null) {
            return Optional<T>.none();
          } else {
            return Optional<T>.some(element);
          }
        },
      ),
    );
  }

  FoldSet<Whole, MapEntry<Key, T>> get folded => asFoldList().folded;
}

extension MapOpticsFoldListExtension<Whole, Key, T> on FoldList<Whole, Map<Key, T>> {
  FoldList<Whole, T> at(Key key) {
    return composeWithPreview(
      Preview<Map<Key, T>, T>(
        (whole) {
          final element = whole[key];
          if (element == null) {
            return Optional<T>.none();
          } else {
            return Optional<T>.some(element);
          }
        },
      ),
    );
  }

  FoldSet<Whole, MapEntry<Key, T>> get folded => asFoldSet().folded;
}

extension MapOpticsFoldSetExtension<Whole, Key, T> on FoldSet<Whole, Map<Key, T>> {
  FoldSet<Whole, T> at(Key key) {
    return composeWithPreview(
      Preview<Map<Key, T>, T>(
        (whole) {
          final element = whole[key];
          if (element == null) {
            return Optional<T>.none();
          } else {
            return Optional<T>.some(element);
          }
        },
      ),
    );
  }

  FoldSet<Whole, MapEntry<Key, T>> get folded {
    return compose(FoldSet((whole) {
      if (whole.isEmpty) {
        return {};
      } else {
        return whole.entries.toSet();
      }
    }));
  }
}

extension MapOpticsMutatorExtension<Whole, Key, T> on Mutator<Whole, Map<Key, T>> {
  Mutator<Whole, T> at(Key key) {
    return compose(
      Mutator.affine<Map<Key, T>, T>(
        Preview<Map<Key, T>, T>((whole) {
          final element = whole[key];
          if (element == null) {
            return Optional<T>.none();
          } else {
            return Optional<T>.some(element);
          }
        }),
        Getter((part) {
          return Getter((whole) {
            if (whole.isEmpty) {
              return whole;
            }

            whole[key] = part;
            return whole;
          });
        }),
      ),
    );
  }

  Mutator<Whole, MapEntry<Key, T>> get traversed {
    return compose(
      Mutator.traversalSet(
        FoldSet((whole) {
          if (whole.isEmpty) {
            return {};
          } else {
            return whole.entries.toSet();
          }
        }),
        Getter((part) {
          return Getter((_) {
            final Map<Key, T> copy = {};
            copy.addEntries(part.asSet());
            return copy;
          });
        }),
      ),
    );
  }
}

extension MapOpticsBiEqvExtension<Key, T> on BiEqv<Map<Key, T>> {
  Mutator<Map<Key, T>, T> at(Key key) {
    return asMutator().at(key);
  }

  Mutator<Map<Key, T>, MapEntry<Key, T>> get traversed {
    return asMutator().traversed;
  }
}

extension MapOpticsIsoExtension<Whole, Key, T> on Iso<Whole, Map<Key, T>> {
  Mutator<Whole, T> at(Key key) {
    return asMutator().at(key);
  }

  Mutator<Whole, MapEntry<Key, T>> get traversed {
    return asMutator().traversed;
  }
}

extension MapOpticsPrismExtension<Whole, Key, T> on Prism<Whole, Map<Key, T>> {
  Mutator<Whole, T> at(Key key) {
    return asMutator().at(key);
  }

  Mutator<Whole, MapEntry<Key, T>> get traversed {
    return asMutator().traversed;
  }
}

extension MapOpticsReflectorExtension<Whole, Key, T> on Reflector<Whole, Map<Key, T>> {
  Mutator<Whole, T> at(Key key) {
    return asMutator().at(key);
  }

  Mutator<Whole, MapEntry<Key, T>> get traversed {
    return asMutator().traversed;
  }
}

extension MapOpticsBiPreviewExtension<Whole, Key, T> on BiPreview<Whole, Map<Key, T>> {
  Mutator<Whole, T> at(Key key) {
    return asMutator().at(key);
  }

  Mutator<Whole, MapEntry<Key, T>> get traversed {
    return asMutator().traversed;
  }
}
