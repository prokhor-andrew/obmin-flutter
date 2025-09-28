// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/call.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/dict.dart';
import 'package:obmin/types/list.dart';
import 'package:obmin/types/logger.dart';
import 'package:obmin/types/option.dart';
import 'package:obmin/types/result.dart';
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

  static PolyOptic<Writer<E, Part>, Writer<E, TPart>, Part, TPart> writerValue<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<Writer<Part, E>, Writer<TPart, E>, IList<Part>, IList<TPart>> writerList<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (writer) {
        return Writer(update(writer.list()), writer.value());
      };
    });
  }

  static PolyOptic<Either<E, Part>, Either<E, TPart>, Part, TPart> eitherRight<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<Either<Part, E>, Either<TPart, E>, Part, TPart> eitherLeft<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.lmap(update);
      };
    });
  }

  static PolyOptic<Call<E, Part>, Call<E, TPart>, Part, TPart> callReturned<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<Call<Part, E>, Call<TPart, E>, Part, TPart> callLaunched<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.lmap(update);
      };
    });
  }

  static PolyOptic<Result<E, Part>, Result<E, TPart>, Part, TPart> resultSuccess<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<Result<Part, E>, Result<TPart, E>, Part, TPart> resultFailure<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.lmap(update);
      };
    });
  }

  static PolyOptic<These<E, Part>, These<E, TPart>, Part, TPart> theseRight<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<These<Part, E>, These<TPart, E>, Part, TPart> theseLeft<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.lmap(update);
      };
    });
  }

  static PolyOptic<(E, Part), (E, TPart), Part, TPart> tupleRight<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<(Part, E), (TPart, E), Part, TPart> tupleLeft<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.lmap(update);
      };
    });
  }

  static PolyOptic<Validator<E, Part>, Validator<E, TPart>, Part, TPart> validatorValue<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (functor) {
        return functor.rmap(update);
      };
    });
  }

  static PolyOptic<Validator<Part, E>, Validator<TPart, E>, IList<Part>, IList<TPart>> validatorErrors<E, Part, TPart>() {
    return PolyOptic.fromRun((update) {
      return (validator) {
        return validator.match((errors) {
          return Validator.errors(update(errors));
        }, (value) {
          return Validator.of(value);
        });
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

  static PolyOptic<IMap<Key, Part>, IMap<Key, TPart>, Part, TPart> dict<Key, Part, TPart>() {
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
