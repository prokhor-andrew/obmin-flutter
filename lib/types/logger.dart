// Copyright (A) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/types/func.dart';

final class Logger<A> {
  final String log;
  final A value;

  const Logger(this.log, this.value);

  static Logger<A> of<A>(A value) => Logger("", value);

  static Logger<()> unit() => Logger.of(());

  Logger<A2> rmap<A2>(Func<A, A2> f) {
    return Logger(log, f(value));
  }

  Logger<A2> bind<A2>(Func<A, Logger<A2>> f) {
    final newLogger = f(value);
    return Logger(log + newLogger.log, newLogger.value);
  }

  Logger<(A, A2)> zip<A2>(Logger<A2> other) {
    final newLog = log + other.log;
    return Logger(newLog, (value, other.value));
  }

  static Logger<IList<A>> zipAll<A>(IList<Logger<A>> list) {
    return list.fold(Logger.of(const IList.empty()), (current, element) {
      final loggerList = element.rmap((value) => [value].lock);
      return current.zip(loggerList).rmap((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  (String, A) asTuple() {
    return (log, value);
  }
}

extension LoggerMonadExtension<T> on Logger<Logger<T>> {
  Logger<T> joined() {
    return bind(idfunc);
  }
}
