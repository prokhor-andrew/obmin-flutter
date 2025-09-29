// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/logger.dart';

final class LoggerArrow<Whole, Part> {
  final Func<Whole, Logger<Part>> run;

  const LoggerArrow._(this.run);

  static LoggerArrow<Whole, Part> fromRun<Whole, Part>(Func<Whole, Logger<Part>> run) {
    return LoggerArrow._(run);
  }

  static LoggerArrow<Whole, Part> fromFunc<Whole, Part>(Func<Whole, Part> f) {
    return fromRun<Whole, Part>((whole) {
      final part = f(whole);
      return LoggerArrow.id<Part>().run(part);
    });
  }

  static LoggerArrow<Whole, ()> unit<Whole>() {
    return LoggerArrow.fromRun<Whole, ()>(constfunc<Whole, Logger<()>>(Logger.of<()>(())));
  }

  LoggerArrow<Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return LoggerArrow.fromRun<Whole, Part2>((whole) {
      return run(whole).rmap<Part2>(f);
    });
  }

  LoggerArrow<Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return LoggerArrow.fromRun<Whole2, Part>((whole2) {
      return run(f(whole2));
    });
  }

  LoggerArrow<Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap<Whole2>(lf).rmap<Part2>(rf);
  }

  static LoggerArrow<A, A> id<A>() {
    return LoggerArrow.fromRun<A, A>(Logger.of<A>);
  }

  LoggerArrow<Whole, Sub> then<Sub>(LoggerArrow<Part, Sub> other) {
    return LoggerArrow.fromRun<Whole, Sub>((whole) {
      return run(whole).bind<Sub>(other.run);
    });
  }

  LoggerArrow<Whole2, Part> after<Whole2>(LoggerArrow<Whole2, Whole> other) {
    return other.then<Part>(this);
  }

  LoggerArrow<Whole, (Part, Part2)> zip<Part2>(LoggerArrow<Whole, Part2> other) {
    return LoggerArrow.fromRun<Whole, (Part, Part2)>((whole) {
      return run(whole).zip<Part2>(other.run(whole));
    });
  }

  static LoggerArrow<Whole, IList<Part>> zipAll<Whole, Part>(IList<LoggerArrow<Whole, Part>> list) {
    return list.fold<LoggerArrow<Whole, IList<Part>>>(LoggerArrow.fromRun<Whole, IList<Part>>((_) => Logger.of<IList<Part>>(IList<Part>.empty())), (current, element) {
      final arrow = element.rmap<IList<Part>>((value) => [value].lock);
      return current.zip<IList<Part>>(arrow).rmap<IList<Part>>((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  LoggerArrow<(A, Whole), (A, Part)> strong<A>() {
    return LoggerArrow.fromRun<(A, Whole), (A, Part)>((tuple) {
      final (a, whole) = tuple;
      final functor = run(whole);
      return functor.rmap<(A, Part)>((part) => (a, part));
    });
  }

  LoggerArrow<Either<A, Whole>, Either<A, Part>> choice<A>() {
    return LoggerArrow.fromRun<Either<A, Whole>, Either<A, Part>>((either) {
      return either.match<Logger<Either<A, Part>>>((a) {
        return id<Either<A, Part>>().run(Either.left<A, Part>(a));
      }, (whole) {
        final functor = run(whole);
        return functor.rmap<Either<A, Part>>((part) => Either.right<A, Part>(part));
      });
    });
  }
}
