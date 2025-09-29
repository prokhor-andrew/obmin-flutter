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
    return fromRun((whole) {
      final part = f(whole);
      return LoggerArrow.id<Part>().run(part);
    });
  }

  static LoggerArrow<Whole, ()> unit<Whole>() {
    return LoggerArrow.fromRun(constfunc(Logger.of(())));
  }

  LoggerArrow<Whole, Part2> rmap<Part2>(Func<Part, Part2> f) {
    return LoggerArrow.fromRun((whole) {
      return run(whole).rmap(f);
    });
  }

  LoggerArrow<Whole2, Part> cmap<Whole2>(Func<Whole2, Whole> f) {
    return LoggerArrow.fromRun((whole2) {
      return run(f(whole2));
    });
  }

  LoggerArrow<Whole2, Part2> promap<Whole2, Part2>(Func<Whole2, Whole> lf, Func<Part, Part2> rf) {
    return cmap(lf).rmap(rf);
  }

  static LoggerArrow<A, A> id<A>() {
    return LoggerArrow.fromRun(Logger.of);
  }

  LoggerArrow<Whole, Sub> then<Sub>(LoggerArrow<Part, Sub> other) {
    return LoggerArrow.fromRun((whole) {
      return run(whole).bind(other.run);
    });
  }

  LoggerArrow<Whole2, Part> after<Whole2>(LoggerArrow<Whole2, Whole> other) {
    return other.then(this);
  }

  LoggerArrow<Whole, (Part, Part2)> zip<Part2>(LoggerArrow<Whole, Part2> other) {
    return LoggerArrow.fromRun((whole) {
      return run(whole).zip(other.run(whole));
    });
  }

  static LoggerArrow<Whole, IList<Part>> zipAll<Whole, Part>(IList<LoggerArrow<Whole, Part>> list) {
    return list.fold(LoggerArrow.id(), (current, element) {
      final arrow = element.rmap((value) => [value].lock);
      return current.zip(arrow).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  LoggerArrow<(A, Whole), (A, Part)> strong<A>() {
    return LoggerArrow.fromRun((tuple) {
      final (a, whole) = tuple;
      final functor = run(whole);
      return functor.rmap((part) => (a, part));
    });
  }

  LoggerArrow<Either<A, Whole>, Either<A, Part>> choice<A>() {
    return LoggerArrow.fromRun((either) {
      return either.match((a) {
        return id<Either<A, Part>>().run(Either.left(a));
      }, (whole) {
        final functor = run(whole);
        return functor.rmap((part) => Either.right(part));
      });
    });
  }
}
