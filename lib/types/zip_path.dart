// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/func.dart';
import 'package:obmin/types/dict.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/option.dart';

final class ZipPath<K, T> {
  final Either<T, IMap<IList<K>, T>> _mapOrNone;

  const ZipPath._(this._mapOrNone);

  ZipPath<K, T2> rmap<T2>(Func<T, T2> f) => ZipPath._(_mapOrNone.lmap(f).rmap((map) => map.rmap(f)));

  static ZipPath<K, ()> unit<K>() => ZipPath._(Either.left(()));

  static ZipPath<K, T> infinite<K, T>(T value) => unit<K>().rmap(constfunc(value));

  static ZipPath<K, T> fromMap<K, T>(IMap<IList<K>, T> map) => ZipPath._(Either.right(map));

  ZipPath<K, (T, T2)> zip<T2>(ZipPath<K, T2> other) {
    return _mapOrNone.match((infiniteValue) {
      return other._mapOrNone.match((infiniteValue2) {
        return ZipPath._(Either.left((infiniteValue, infiniteValue2)));
      }, (map2) {
        return ZipPath._(Either.right(map2.rmap((value2) => (infiniteValue, value2))));
      });
    }, (map) {
      return other._mapOrNone.match((infiniteValue2) {
        return ZipPath._(Either.right(map.rmap((value) => (value, infiniteValue2))));
      }, (map2) {
        IMap<IList<K>, (T, T2)> result = IMap<IList<K>, (T, T2)>.empty();

        map.forEach((k, v) {
          if (!map2.containsKey(k)) {
            return;
          }

          result = result.add(k, (v, map2.get(k) as T2));
        });

        return ZipPath._(Either.right(result));
      });
    });
  }

  static ZipPath<K, IList<T>> zipAll<K, T>(IList<ZipPath<K, T>> list) {
    return list.fold<ZipPath<K, IList<T>>>(ZipPath.infinite<K, IList<T>>(IList<T>.empty()), (current, element) {
      final path = element.rmap<IList<T>>((value) => [value].lock);
      return current.zip<IList<T>>(path).rmap<IList<T>>((tuple) => tuple.$1.addAll(tuple.$2));
    });
  }

  Option<T> get(IList<K> key) {
    return _mapOrNone.match(Option.some, (map) {
      if (!map.containsKey(key)) {
        return Option.none();
      }
      final value = map.get(key);
      return Option.some(value as T);
    });
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ZipPath<K, T>) return false;

    return _mapOrNone.match((infiniteValue) {
      return other._mapOrNone.match(
        (infiniteValue2) => infiniteValue == infiniteValue2,
        constfunc(false),
        //
      );
    }, (map) {
      return other._mapOrNone.match(
        constfunc(false),
        (map2) => map == map2,
        //
      );
    });
  }

  @override
  int get hashCode => _mapOrNone.match((infiniteValue) => infiniteValue.hashCode, (map) => map.hashCode);

  Option<int> lengthOrInfinite() => _mapOrNone.match(constfunc(Option.none()), (map) => Option.some(map.length));

  bool isInfinite() => _mapOrNone.isLeft();

  bool isFinite() => !isInfinite();
}
