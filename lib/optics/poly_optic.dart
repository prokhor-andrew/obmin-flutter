// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/flist.dart';
import 'package:obmin/types/func.dart';
import 'package:obmin/types/list.dart';
import 'package:obmin/types/logger.dart';
import 'package:obmin/types/option.dart';
import 'package:obmin/types/these.dart';
import 'package:obmin/types/tuple.dart';
import 'package:obmin/types/validator.dart';
import 'package:obmin/types/writer.dart';

final class PolyOptic<Whole, TWhole, Part, TPart> {
  final Func<Func<Part, TPart>, Func<Whole, TWhole>> run;

  Func<Whole, TWhole> set(TPart value) => run(constfunc(value));

  const PolyOptic._(this.run);

  static PolyOptic<Whole, TWhole, Part, TPart> fromRun<Whole, TWhole, Part, TPart>(Func<Func<Part, TPart>, Func<Whole, TWhole>> run) {
    return PolyOptic._(run);
  }

  static PolyOptic<T, T, T, T> id<T>() {
    return PolyOptic.fromRun(idfunc);
  }

  static PolyOptic<Whole, TWhole, Part, TPart> adapter<Whole, TWhole, Part, TPart>(
    Func<Whole, Part> focus,
    Func<TPart, TWhole> reconstruct,
  ) {
    return PolyOptic.fromRun((update) {
      return (whole) {
        final part = focus(whole);
        final updated = update(part);
        return reconstruct(updated);
      };
    });
  }

  static PolyOptic<Whole, TWhole, Part, TPart> lens<Whole, TWhole, Part, TPart>(
    Func<Whole, Part> focus,
    Func<Whole, Func<TPart, TWhole>> reconstruct,
  ) {
    return PolyOptic.fromRun((update) {
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
    return PolyOptic.fromRun((update) {
      return (whole) {
        final partOrNewWhole = focus(whole);
        final updatedOrNewWhole = partOrNewWhole.rmap(update);
        return updatedOrNewWhole.rmap(reconstruct).value();
      };
    });
  }

  static PolyOptic<IList<Part>, IList<TPart>, Part, TPart> list<Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<Option<Part>, Option<TPart>, Part, TPart> option<Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<Writer<E, Part>, Writer<E, TPart>, Part, TPart> writer<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<Either<E, Part>, Either<E, TPart>, Part, TPart> either<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<These<E, Part>, These<E, TPart>, Part, TPart> these<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<(E, Part), (E, TPart), Part, TPart> tuple<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<Validator<E, Part>, Validator<E, TPart>, Part, TPart> validator<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<FList<Part>, FList<TPart>, Part, TPart> flist<Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<Logger<Part>, Logger<TPart>, Part, TPart> logger<Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  PolyOptic<Whole, TWhole, Sub, TSub> then<Sub, TSub>(PolyOptic<Part, TPart, Sub, TSub> other) {
    return PolyOptic.fromRun((update) {
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
