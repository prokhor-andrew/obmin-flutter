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

extension ListOpticsEqvExtension<T> on Eqv<List<T>> {
  FoldList<List<T>, T> get folded => asGetter().folded;

  Preview<List<T>, T> find(bool Function(T element) function) {
    return asGetter().find(function);
  }

  Getter<List<T>, int> get length => asGetter().length;

  Preview<List<T>, T> get last => asGetter().last;

  Preview<List<T>, T> get first => asGetter().first;

  Preview<List<T>, T> at(int index) {
    return asGetter().at(index);
  }
}

extension ListOpticsGetterExtension<Whole, T> on Getter<Whole, List<T>> {
  FoldList<Whole, T> get folded => asPreview().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return asPreview().find(function);
  }

  Getter<Whole, int> get length => compose(Getter<List<T>, int>((whole) => whole.length));

  Preview<Whole, T> get last => asPreview().last;

  Preview<Whole, T> get first => asPreview().first;

  Preview<Whole, T> at(int index) {
    return asPreview().at(index);
  }
}

extension ListOpticsPreviewExtension<Whole, T> on Preview<Whole, List<T>> {
  FoldList<Whole, T> get folded => asFoldList().folded;

  Preview<Whole, T> find(bool Function(T element) function) {
    return compose(
      Preview<List<T>, T>(
        (whole) {
          for (final element in whole) {
            if (function(element)) {
              return Optional.some(element);
            }
          }
          return Optional.none();
        },
      ),
    );
  }

  Preview<Whole, int> get length => composeWithGetter(Getter<List<T>, int>((whole) => whole.length));

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

extension ListOpticsFoldListExtension<Whole, T> on FoldList<Whole, List<T>> {
  FoldList<Whole, T> get folded => compose(FoldList<List<T>, T>((whole) => whole));

  FoldList<Whole, T> find(bool Function(T element) function) {
    return composeWithPreview(
      Preview<List<T>, T>(
        (whole) {
          for (final element in whole) {
            if (function(element)) {
              return Optional.some(element);
            }
          }
          return Optional.none();
        },
      ),
    );
  }

  FoldList<Whole, int> get length => composeWithGetter(Getter<List<T>, int>((whole) => whole.length));

  FoldList<Whole, T> get last => composeWithPreview(
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

  FoldList<Whole, T> get first => composeWithPreview(
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

  FoldList<Whole, T> at(int index) {
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

extension ListOpticsFoldSetExtension<Whole, T> on FoldSet<Whole, List<T>> {
  FoldSet<Whole, T> get folded => compose(FoldSet<List<T>, T>((whole) => whole.toSet()));

  FoldSet<Whole, T> find(bool Function(T element) function) {
    return composeWithPreview(
      Preview<List<T>, T>(
        (whole) {
          for (final element in whole) {
            if (function(element)) {
              return Optional.some(element);
            }
          }
          return Optional.none();
        },
      ),
    );
  }

  FoldSet<Whole, int> get length => composeWithGetter(Getter<List<T>, int>((whole) => whole.length));

  FoldSet<Whole, T> get last => composeWithPreview(
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

  FoldSet<Whole, T> get first => composeWithPreview(
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

  FoldSet<Whole, T> at(int index) {
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
  Mutator<Whole, T> get traversed => compose(
        Mutator.traversalList<List<T>, T>(
          FoldList<List<T>, T>((whole) => whole),
          Getter((part) => Getter((_) => part.asList())),
        ),
      );

  Mutator<Whole, T> find(bool Function(T element) function) {
    return compose(
      Mutator.affine(Preview<List<T>, T>((whole) {
        for (final element in whole) {
          if (function(element)) {
            return Optional.some(element);
          }
        }
        return Optional.none();
      }), Getter(
        (part) {
          return Getter((whole) {
            final copy = whole.toList();
            final index = copy.indexWhere(function);
            if (index == -1) {
              return whole;
            }

            copy.removeAt(index);
            copy.insert(index, part);
            return copy;
          });
        },
      )),
    );
  }

  Mutator<Whole, T> get last => compose(
        Mutator.affine<List<T>, T>(Preview<List<T>, T>((whole) {
          if (whole.isEmpty) {
            return Optional<T>.none();
          } else {
            return Optional<T>.some(whole.last);
          }
        }), Getter(
          (part) {
            return Getter((whole) {
              if (whole.isEmpty) {
                return whole;
              }
              final copy = whole.toList();

              final indexOfLastElement = whole.length - 1;
              copy.removeAt(indexOfLastElement);
              copy.insert(indexOfLastElement, part);

              return copy;
            });
          },
        )),
      );

  Mutator<Whole, T> get first => compose(
        Mutator.affine<List<T>, T>(Preview<List<T>, T>((whole) {
          if (whole.isEmpty) {
            return Optional<T>.none();
          } else {
            return Optional<T>.some(whole.last);
          }
        }), Getter(
          (part) {
            return Getter((whole) {
              if (whole.isEmpty) {
                return whole;
              }
              final copy = whole.toList();

              copy.removeAt(0);
              copy.insert(0, part);

              return copy;
            });
          },
        )),
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
        Getter((part) {
          return Getter((whole) {
            if (index < 0 || index >= whole.length) {
              return whole;
            }

            final copy = whole.toList();
            copy.removeAt(index);
            copy.insert(index, part);
            return copy;
          });
        }),
      ),
    );
  }
}

extension ListOpticsBiEqvExtension<T> on BiEqv<List<T>> {
  Mutator<List<T>, T> get traversed => asMutator().traversed;

  Mutator<List<T>, T> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension ListOpticsIsoExtension<Whole, T> on Iso<Whole, List<T>> {
  Mutator<Whole, T> get traversed => asMutator().traversed;

  Mutator<Whole, T> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension ListOpticsPrismExtension<Whole, T> on Prism<Whole, List<T>> {
  Mutator<Whole, T> get traversed => asMutator().traversed;

  Mutator<Whole, T> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension ListOpticsReflectorExtension<Whole, T> on Reflector<Whole, List<T>> {
  Mutator<Whole, T> get traversed => asMutator().traversed;

  Mutator<Whole, T> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}

extension ListOpticsBiPreviewExtension<Whole, T> on BiPreview<Whole, List<T>> {
  Mutator<Whole, T> get traversed => asMutator().traversed;

  Mutator<Whole, T> find(bool Function(T element) function) {
    return asMutator().find(function);
  }
}
