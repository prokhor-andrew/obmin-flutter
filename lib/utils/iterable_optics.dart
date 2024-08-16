// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:collection/collection.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/bidirect/bi_preview.dart';
import 'package:obmin/optics/bidirect/iso.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/bidirect/prism.dart';
import 'package:obmin/optics/bidirect/reflector.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/types/optional.dart';

extension IterableOpticsEqvExtension<T> on Eqv<Iterable<T>> {
  Fold<Iterable<T>, T> get folded => asGetter().folded;

  Preview<Iterable<T>, T> find(bool Function(T element) function) {
    return asGetter().find(function);
  }

  Getter<Iterable<T>, int> get length => asGetter().length;
}

extension IterableOpticsGetterExtension<Whole, T> on Getter<Whole, Iterable<T>> {
  Fold<Whole, T> get folded => asPreview().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return asPreview().find(function);
  }

  Getter<Whole, int> get length => compose(Getter<Iterable<T>, int>((whole) => whole.length));
}

extension IterableOpticsPreviewExtension<Whole, T> on Preview<Whole, Iterable<T>> {
  Fold<Whole, T> get folded => asFold().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return compose(
      Preview<Iterable<T>, T>(
        (whole) {
          final found = whole.firstWhereOrNull(function);
          if (found == null) {
            return Optional<T>.none();
          } else {
            return Optional<T>.some(found);
          }
        },
      ),
    );
  }

  Preview<Whole, int> get length => composeWithGetter(Getter<Iterable<T>, int>((whole) => whole.length));
}

extension IterableOpticsFoldExtension<Whole, T> on Fold<Whole, Iterable<T>> {
  Fold<Whole, T> get folded => compose(Fold<Iterable<T>, T>((whole) => whole));

  Fold<Whole, T> find(bool Function(T element) function) {
    return composeWithPreview(
      Preview<Iterable<T>, T>(
        (whole) {
          final found = whole.firstWhereOrNull(function);
          if (found == null) {
            return Optional<T>.none();
          } else {
            return Optional<T>.some(found);
          }
        },
      ),
    );
  }

  Fold<Whole, int> get length => composeWithGetter(Getter<Iterable<T>, int>((whole) => whole.length));
}

extension IterableOpticsMutatorExtension<Whole, T> on Mutator<Whole, Iterable<T>> {
  Mutator<Whole, T> get traversed => compose(
        Mutator.traversal<Iterable<T>, T>(
          Fold<Iterable<T>, T>((whole) => whole),
          (whole, part) => part,
        ),
      );

  Mutator<Whole, T> find(bool Function(T element) function) {
    return compose(
      Mutator.affine(
        Preview<Iterable<T>, T>((whole) {
          final found = whole.firstWhereOrNull(function);
          if (found == null) {
            return Optional<T>.none();
          } else {
            return Optional<T>.some(found);
          }
        }),
        (whole, part) {
          final copy = whole.toList();
          final index = copy.indexWhere(function);
          if (index == -1) {
            return whole;
          }

          copy.removeAt(index);
          copy.insert(index, part);
          return copy;
        },
      ),
    );
  }
}

extension IterableOpticsIsoExtension<Whole, T> on Iso<Whole, Iterable<T>> {
  Mutator<Whole, T> get traversed => asMutator().traversed;

  Mutator<Whole, T> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension IterableOpticsPrismExtension<Whole, T> on Prism<Whole, Iterable<T>> {
  Mutator<Whole, T> get traversed => asMutator().traversed;

  Mutator<Whole, T> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension IterableOpticsReflectorExtension<Whole, T> on Reflector<Whole, Iterable<T>> {
  Mutator<Whole, T> get traversed => asMutator().traversed;

  Mutator<Whole, T> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension IterableOpticsBiPreviewExtension<Whole, T> on BiPreview<Whole, Iterable<T>> {
  Mutator<Whole, T> get traversed => asMutator().traversed;

  Mutator<Whole, T> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension ListOpticsEqvExtension<T> on Eqv<List<T>> {
  Preview<List<T>, T> get last => asGetter().last;

  Preview<List<T>, T> get first => asGetter().first;

  Preview<List<T>, T> at(int index) {
    return asGetter().at(index);
  }
}

extension ListOpticsGetterExtension<Whole, T> on Getter<Whole, List<T>> {
  Preview<Whole, T> get last => asPreview().last;

  Preview<Whole, T> get first => asPreview().first;

  Preview<Whole, T> at(int index) {
    return asPreview().at(index);
  }
}

extension ListOpticsPreviewExtension<Whole, T> on Preview<Whole, List<T>> {
  Preview<Whole, T> get last => compose(
        Preview<List<T>, T>(
          (whole) {
            if (whole.isEmpty) {
              return Optional<T>.none();
            } else {
              return Optional<T>.some(whole.last);
            }
          },
        ),
      );

  Preview<Whole, T> get first => compose(
        Preview<List<T>, T>(
          (whole) {
            if (whole.isEmpty) {
              return Optional<T>.none();
            } else {
              return Optional<T>.some(whole[0]);
            }
          },
        ),
      );

  Preview<Whole, T> at(int index) {
    return compose(
      Preview<List<T>, T>(
        (whole) {
          if (index < 0 || index >= whole.length) {
            return Optional<T>.none();
          } else {
            final element = whole[index];
            return Optional<T>.some(element);
          }
        },
      ),
    );
  }
}

extension ListOpticsFoldExtension<Whole, T> on Fold<Whole, List<T>> {
  Fold<Whole, T> get last => composeWithPreview(
        Preview<List<T>, T>(
          (whole) {
            if (whole.isEmpty) {
              return Optional<T>.none();
            } else {
              return Optional<T>.some(whole.last);
            }
          },
        ),
      );

  Fold<Whole, T> get first => composeWithPreview(
        Preview<List<T>, T>(
          (whole) {
            if (whole.isEmpty) {
              return Optional<T>.none();
            } else {
              return Optional<T>.some(whole[0]);
            }
          },
        ),
      );

  Fold<Whole, T> at(int index) {
    return composeWithPreview(
      Preview<List<T>, T>(
        (whole) {
          if (index < 0 || index >= whole.length) {
            return Optional<T>.none();
          } else {
            final element = whole[index];
            return Optional<T>.some(element);
          }
        },
      ),
    );
  }
}

extension ListOpticsMutatorExtension<Whole, T> on Mutator<Whole, List<T>> {
  Mutator<Whole, T> get last => compose(
        Mutator.affine<List<T>, T>(
          Preview<List<T>, T>((whole) {
            if (whole.isEmpty) {
              return Optional<T>.none();
            } else {
              return Optional<T>.some(whole.last);
            }
          }),
          (whole, part) {
            if (whole.isEmpty) {
              return whole;
            }
            final copy = whole.toList();

            final indexOfLastElement = whole.length - 1;
            copy.removeAt(indexOfLastElement);
            copy.insert(indexOfLastElement, part);

            return copy;
          },
        ),
      );

  Mutator<Whole, T> get first => compose(
        Mutator.affine<List<T>, T>(
          Preview<List<T>, T>((whole) {
            if (whole.isEmpty) {
              return Optional<T>.none();
            } else {
              return Optional<T>.some(whole.last);
            }
          }),
          (whole, part) {
            if (whole.isEmpty) {
              return whole;
            }
            final copy = whole.toList();

            copy.removeAt(0);
            copy.insert(0, part);

            return copy;
          },
        ),
      );

  Mutator<Whole, T> at(int index) {
    return compose(
      Mutator.affine<List<T>, T>(
        Preview<List<T>, T>((whole) {
          if (index < 0 || index >= whole.length) {
            return Optional<T>.none();
          } else {
            return Optional<T>.some(whole.last);
          }
        }),
        (whole, part) {
          if (index < 0 || index >= whole.length) {
            return whole;
          }

          final copy = whole.toList();
          copy.removeAt(index);
          copy.insert(index, part);
          return copy;
        },
      ),
    );
  }
}

extension MapOpticsEqvExtension<Key, T> on Eqv<Map<Key, T>> {
  Preview<Map<Key, T>, T> at(Key key) {
    return asGetter().at(key);
  }
}

extension MapOpticsGetterExtension<Whole, Key, T> on Getter<Whole, Map<Key, T>> {
  Preview<Whole, T> at(Key key) {
    return asPreview().at(key);
  }
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
}

extension MapOpticsFoldExtension<Whole, Key, T> on Fold<Whole, Map<Key, T>> {
  Fold<Whole, T> at(Key key) {
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
        (whole, part) {
          if (whole.isEmpty) {
            return whole;
          }

          whole[key] = part;
          return whole;
        },
      ),
    );
  }
}

extension MapOpticsIsoExtension<Whole, Key, T> on Iso<Whole, Map<Key, T>> {
  Mutator<Whole, T> at(Key key) {
    return asMutator().at(key);
  }
}

extension MapOpticsPrismExtension<Whole, Key, T> on Prism<Whole, Map<Key, T>> {
  Mutator<Whole, T> at(Key key) {
    return asMutator().at(key);
  }
}

extension MapOpticsReflectorExtension<Whole, Key, T> on Reflector<Whole, Map<Key, T>> {
  Mutator<Whole, T> at(Key key) {
    return asMutator().at(key);
  }
}

extension MapOpticsBiPreviewExtension<Whole, Key, T> on BiPreview<Whole, Map<Key, T>> {
  Mutator<Whole, T> at(Key key) {
    return asMutator().at(key);
  }
}
