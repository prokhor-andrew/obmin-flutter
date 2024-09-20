// // Copyright (c) 2024 Andrii Prokhorenko
// // This file is part of Obmin, licensed under the MIT License.
// // See the LICENSE file in the project root for license information.
// //
//
// extension SetOpticsEqvExtension<T> on Eqv<Set<T>> {
//   FoldSet<Set<T>, T> get folded => asGetter().folded;
//
//   Preview<Set<T>, T> find(bool Function(T element) function) {
//     return asGetter().find(function);
//   }
//
//   Getter<Set<T>, int> get length => asGetter().length;
// }
//
// extension SetOpticsGetterExtension<Whole, T> on Getter<Whole, Set<T>> {
//   FoldSet<Whole, T> get folded => asPreview().folded;
//
//   Preview<Whole, T> find(bool Function(T element) function) {
//     return asPreview().find(function);
//   }
//
//   Getter<Whole, int> get length => compose(Getter<Set<T>, int>((whole) => whole.length));
// }
//
// extension SetOpticsPreviewExtension<Whole, T> on Preview<Whole, Set<T>> {
//   FoldSet<Whole, T> get folded => asFoldSet().folded;
//
//   Preview<Whole, T> find(bool Function(T element) function) {
//     return compose(
//       Preview<Set<T>, T>(
//             (whole) {
//           for (final element in whole) {
//             if (function(element)) {
//               return Optional.some(element);
//             }
//           }
//           return Optional.none();
//         },
//       ),
//     );
//   }
//
//   Preview<Whole, int> get length => composeWithGetter(Getter<Set<T>, int>((whole) => whole.length));
// }
//
// extension SetOpticsFoldSetExtension<Whole, T> on FoldSet<Whole, Set<T>> {
//   FoldSet<Whole, T> get folded => compose(FoldSet<Set<T>, T>((whole) => whole));
//
//   FoldSet<Whole, T> find(bool Function(T element) function) {
//
//     return composeWithPreview(
//       Preview<Set<T>, T>(
//             (whole) {
//           for (final element in whole) {
//             if (function(element)) {
//               return Optional.some(element);
//             }
//           }
//           return Optional.none();
//         },
//       ),
//     );
//   }
//
//   FoldSet<Whole, int> get length => composeWithGetter(Getter<Set<T>, int>((whole) => whole.length));
// }
//
// extension SetOpticsMutatorExtension<Whole, T> on Mutator<Whole, Set<T>> {
//   Mutator<Whole, T> get traversed => compose(
//     Mutator.traversalSet<Set<T>, T>(
//       FoldSet<Set<T>, T>((whole) => whole),
//       Getter((part) => Getter((_) => part.asSet())),
//     ),
//   );
//
//   Mutator<Whole, T> find(bool Function(T element) function) {
//     return compose(
//       Mutator.affine(Preview<Set<T>, T>((whole) {
//         for (final element in whole) {
//           if (function(element)) {
//             return Optional.some(element);
//           }
//         }
//         return Optional.none();
//       }), Getter(
//             (part) {
//           return Getter((whole) {
//             final copy = whole.toList();
//             final index = copy.indexWhere(function);
//             if (index == -1) {
//               return whole;
//             }
//
//             copy.removeAt(index);
//             copy.insert(index, part);
//
//             return copy.toSet();
//           });
//         },
//       )),
//     );
//   }
// }
//
// extension SetOpticsIsoExtension<Whole, T> on Iso<Whole, Set<T>> {
//   Mutator<Whole, T> get traversed => asMutator().traversed;
//
//   Mutator<Whole, T> find(bool Function(T element) function) {
//     return asMutator().find(function);
//   }
// }
//
// extension SetOpticsPrismExtension<Whole, T> on Prism<Whole, Set<T>> {
//   Mutator<Whole, T> get traversed => asMutator().traversed;
//
//   Mutator<Whole, T> find(bool Function(T element) function) {
//     return asMutator().find(function);
//   }
// }
//
// extension SetOpticsReflectorExtension<Whole, T> on Reflector<Whole, Set<T>> {
//   Mutator<Whole, T> get traversed => asMutator().traversed;
//
//   Mutator<Whole, T> find(bool Function(T element) function) {
//     return asMutator().find(function);
//   }
// }
//
// extension SetOpticsBiPreviewExtension<Whole, T> on BiPreview<Whole, Set<T>> {
//   Mutator<Whole, T> get traversed => asMutator().traversed;
//
//   Mutator<Whole, T> find(bool Function(T element) function) {
//     return asMutator().find(function);
//   }
// }
//
// extension MapOpticsEqvExtension<Key, T> on Eqv<Map<Key, T>> {
//   Preview<Map<Key, T>, T> at(Key key) {
//     return asGetter().at(key);
//   }
// }
//
// extension MapOpticsGetterExtension<Whole, Key, T> on Getter<Whole, Map<Key, T>> {
//   Preview<Whole, T> at(Key key) {
//     return asPreview().at(key);
//   }
// }
//
// extension MapOpticsPreviewExtension<Whole, Key, T> on Preview<Whole, Map<Key, T>> {
//   Preview<Whole, T> at(Key key) {
//     return compose(
//       Preview<Map<Key, T>, T>(
//             (whole) {
//           final element = whole[key];
//           if (element == null) {
//             return Optional<T>.none();
//           } else {
//             return Optional<T>.some(element);
//           }
//         },
//       ),
//     );
//   }
// }
//
// extension MapOpticsFoldExtension<Whole, Key, T> on Fold<Whole, Map<Key, T>> {
//   Fold<Whole, T> at(Key key) {
//     return composeWithPreview(
//       Preview<Map<Key, T>, T>(
//             (whole) {
//           final element = whole[key];
//           if (element == null) {
//             return Optional<T>.none();
//           } else {
//             return Optional<T>.some(element);
//           }
//         },
//       ),
//     );
//   }
// }
//
// extension MapOpticsMutatorExtension<Whole, Key, T> on Mutator<Whole, Map<Key, T>> {
//   Mutator<Whole, T> at(Key key) {
//     return compose(
//       Mutator.affine<Map<Key, T>, T>(
//         Preview<Map<Key, T>, T>((whole) {
//           final element = whole[key];
//           if (element == null) {
//             return Optional<T>.none();
//           } else {
//             return Optional<T>.some(element);
//           }
//         }),
//         Getter((part) {
//           return Getter((whole) {
//             if (whole.isEmpty) {
//               return whole;
//             }
//
//             whole[key] = part;
//             return whole;
//           });
//         }),
//       ),
//     );
//   }
// }
//
// extension MapOpticsIsoExtension<Whole, Key, T> on Iso<Whole, Map<Key, T>> {
//   Mutator<Whole, T> at(Key key) {
//     return asMutator().at(key);
//   }
// }
//
// extension MapOpticsPrismExtension<Whole, Key, T> on Prism<Whole, Map<Key, T>> {
//   Mutator<Whole, T> at(Key key) {
//     return asMutator().at(key);
//   }
// }
//
// extension MapOpticsReflectorExtension<Whole, Key, T> on Reflector<Whole, Map<Key, T>> {
//   Mutator<Whole, T> at(Key key) {
//     return asMutator().at(key);
//   }
// }
//
// extension MapOpticsBiPreviewExtension<Whole, Key, T> on BiPreview<Whole, Map<Key, T>> {
//   Mutator<Whole, T> at(Key key) {
//     return asMutator().at(key);
//   }
// }
