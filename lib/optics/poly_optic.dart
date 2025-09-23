// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/list.dart';

final class PolyOptic<Whole, TWhole, Part, TPart> {
  final Func<Func<Part, TPart>, Func<Whole, TWhole>> run;

  const PolyOptic(this.run);

  static PolyOptic<T, T, T, T> id<T>() {
    return PolyOptic(idfunc);
  }

  static PolyOptic<Whole, TWhole, Part, TPart> lens<Whole, TWhole, Part, TPart>(
    Func<Whole, Part> focus,
    Func<Whole, Func<TPart, TWhole>> reconstruct,
  ) {
    return PolyOptic((update) {
      return (whole) {
        final part = focus(whole);
        final updated = update(part);
        return reconstruct(whole)(updated);
      };
    });
  }

  static PolyOptic<Whole, TWhole, Part, TPart> prism<Whole, TWhole, Part, TPart>(
    Func<Whole, Either<TWhole, Part>> focus,
    Func<TPart, TWhole> reconstruct,
  ) {
    return PolyOptic((update) {
      return (whole) {
        final partOrNewWhole = focus(whole);
        final updatedOrNewWhole = partOrNewWhole.rmap(update);
        return updatedOrNewWhole.rmap(reconstruct).value();
      };
    });
  }

  static PolyOptic<Whole, TWhole, Part, TPart> affine<Whole, TWhole, Part, TPart>(
    Func<Whole, Either<TWhole, Part>> focus,
    Func<Whole, Func<TPart, TWhole>> reconstruct,
  ) {
    return PolyOptic((update) {
      return (whole) {
        final partOrNewWhole = focus(whole);
        final updatedOrNewWhole = partOrNewWhole.rmap(update);

        return updatedOrNewWhole.rmap(reconstruct(whole)).value();
      };
    });
  }

  static PolyOptic<IList<Part>, IList<TPart>, Part, TPart> each<Part, TPart>() {
    return PolyOptic((update) {
      return (list) {
        return list.rmap(update);
      };
    });
  }

  PolyOptic<Whole, TWhole, Sub, TSub> then<Sub, TSub>(PolyOptic<Part, TPart, Sub, TSub> other) {
    return PolyOptic((update) {
      return (whole) {
        return run((part) {
          return other.run(update)(part);
        })(whole);
      };
    });
  }

  PolyOptic<Whole2, TWhole2, Part, TPart> after<Whole2, TWhole2>(PolyOptic<Whole2, TWhole2, Whole, TWhole> other) {
    return other.then(this);
  }
}

extension PolyOpticToOpticExtension<Whole, Part> on PolyOptic<Whole, Whole, Part, Part> {
  Optic<Whole, Part> asOptic() {
    return Optic(run);
  }
}
