// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:collection/collection.dart';
import 'package:obmin/optics/eqv.dart';
import 'package:obmin/optics/fold.dart';
import 'package:obmin/optics/getter.dart';
import 'package:obmin/optics/preview.dart';
import 'package:obmin/types/optional.dart';

extension IterableOpticsEqvExtension<T> on Eqv<Iterable<T>> {
  Fold<Iterable<T>, T> get folded => asFold().compose(Fold<Iterable<T>, T>((whole) => whole));

  Preview<Iterable<T>, T> find(bool Function(T element) function) {
    return asGetter().find(function);
  }

  Getter<Iterable<T>, int> get length => asGetter().length;
}

extension IterableOpticsGetterExtension<Whole, T> on Getter<Whole, Iterable<T>> {
  Preview<Whole, T> find(bool Function(T element) function) {
    return asPreview().find(function);
  }

  Getter<Whole, int> get length => compose(Getter<Iterable<T>, int>((whole) => whole.length));
}

extension IterableOpticsPreviewExtension<Whole, T> on Preview<Whole, Iterable<T>> {
  Preview<Whole, T> find(bool Function(T element) function) {
    return compose(
      Preview<Iterable<T>, T>(
        (whole) {
          final found = whole.firstWhereOrNull(function);
          if (found == null) {
            return None();
          } else {
            return Some(found);
          }
        },
      ),
    );
  }

  Preview<Whole, int> get length => composeWithGetter(Getter<Iterable<T>, int>((whole) => whole.length));
}

extension IterableOpticsFoldExtension<Whole, T> on Fold<Whole, Iterable<T>> {
  Fold<Whole, T> find(bool Function(T element) function) {
    return composeWithPreview(
      Preview<Iterable<T>, T>(
        (whole) {
          final found = whole.firstWhereOrNull(function);
          if (found == null) {
            return None();
          } else {
            return Some(found);
          }
        },
      ),
    );
  }

  Fold<Whole, int> get length => composeWithGetter(Getter<Iterable<T>, int>((whole) => whole.length));
}

extension ListOpticsEqvExtension<T> on Eqv<List<T>> {
  Preview<List<T>, T> last() {
    return asGetter().last();
  }

  Preview<List<T>, T> first() {
    return asGetter().first();
  }

  Preview<List<T>, T> at(int index) {
    return asGetter().at(index);
  }
}

extension ListOpticsGetterExtension<Whole, T> on Getter<Whole, List<T>> {
  Preview<Whole, T> last() {
    return asPreview().last();
  }

  Preview<Whole, T> first() {
    return asPreview().first();
  }

  Preview<Whole, T> at(int index) {
    return asPreview().at(index);
  }
}

extension ListOpticsPreviewExtension<Whole, T> on Preview<Whole, List<T>> {
  Preview<Whole, T> last() {
    return compose(
      Preview<List<T>, T>(
        (whole) {
          if (whole.isEmpty) {
            return None();
          } else {
            return Some(whole.last);
          }
        },
      ),
    );
  }

  Preview<Whole, T> first() {
    return compose(
      Preview<List<T>, T>(
        (whole) {
          if (whole.isEmpty) {
            return None();
          } else {
            return Some(whole[0]);
          }
        },
      ),
    );
  }

  Preview<Whole, T> at(int index) {
    return compose(
      Preview<List<T>, T>(
        (whole) {
          if (index < 0 || index >= whole.length) {
            return None();
          } else {
            final element = whole[index];
            return Some(element);
          }
        },
      ),
    );
  }
}

extension ListOpticsFoldExtension<Whole, T> on Fold<Whole, List<T>> {
  Fold<Whole, T> last() {
    return composeWithPreview(
      Preview<List<T>, T>(
        (whole) {
          if (whole.isEmpty) {
            return None();
          } else {
            return Some(whole.last);
          }
        },
      ),
    );
  }

  Fold<Whole, T> first() {
    return composeWithPreview(
      Preview<List<T>, T>(
        (whole) {
          if (whole.isEmpty) {
            return None();
          } else {
            return Some(whole[0]);
          }
        },
      ),
    );
  }

  Fold<Whole, T> at(int index) {
    return composeWithPreview(
      Preview<List<T>, T>(
        (whole) {
          if (index < 0 || index >= whole.length) {
            return None();
          } else {
            final element = whole[index];
            return Some(element);
          }
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
            return None();
          } else {
            return Some(element);
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
            return None();
          } else {
            return Some(element);
          }
        },
      ),
    );
  }
}
