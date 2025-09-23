// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/optics/poly_optic.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/list.dart';
import 'package:obmin/types/option.dart';

final class Optic<Whole, Part> {
  final Func<Func<Part, Part>, Func<Whole, Whole>> run;

  const Optic(this.run);

  static Optic<T, T> id<T>() {
    return Optic(idfunc);
  }

  static Optic<Whole, Part> lens<Whole, Part>(
    Func<Whole, Part> focus,
    Func<Whole, Func<Part, Whole>> reconstruct,
  ) {
    return Optic((update) {
      return (whole) {
        final part = focus(whole);
        final updated = update(part);
        return reconstruct(whole)(updated);
      };
    });
  }

  static Optic<Whole, Part> prism<Whole, Part>(
    Func<Whole, Option<Part>> focus,
    Func<Part, Whole> reconstruct,
  ) {
    return Optic((update) {
      return (whole) {
        final partOrNewWhole = focus(whole);
        final updatedOrNone = partOrNewWhole.rmap(update);
        return updatedOrNone.rmap(reconstruct).valueOr(whole);
      };
    });
  }

  static Optic<Whole, Part> affine<Whole, Part>(
    Func<Whole, Option<Part>> focus,
    Func<Whole, Func<Part, Whole>> reconstruct,
  ) {
    return Optic((update) {
      return (whole) {
        final partOrNewWhole = focus(whole);
        final updatedOrNone = partOrNewWhole.rmap(update);

        return updatedOrNone.rmap(reconstruct(whole)).valueOr(whole);
      };
    });
  }

  static Optic<IList<Part>, Part> each<Part, TPart>() {
    return Optic((update) {
      return (list) {
        return list.rmap(update);
      };
    });
  }

  Optic<Whole, Sub> then<Sub>(Optic<Part, Sub> other) {
    return Optic((update) {
      return (whole) {
        return run((part) {
          return other.run(update)(part);
        })(whole);
      };
    });
  }

  Optic<Whole2, Part> after<Whole2>(Optic<Whole2, Whole> other) {
    return other.then(this);
  }

  PolyOptic<Whole, Whole, Part, Part> asPolyOptic() {
    return PolyOptic(run);
  }
}
