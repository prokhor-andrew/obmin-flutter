// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/foundation.dart';
import 'package:obmin/func.dart';

extension ValueListenableExtension<T> on ValueListenable<T> {
  ValueListenable<R> rmap<R>(Func<T, R> transform) => _MappedValueListenable(this, transform);

  ValueListenable<(T, T2)> zip<T2>(ValueListenable<T2> other) => _ZipNotifier._(this, other);
}

final class _MappedValueListenable<T, R> extends ChangeNotifier implements ValueListenable<R> {
  final ValueListenable<T> _source;
  final R Function(T) _transform;

  _MappedValueListenable(this._source, this._transform) {
    _source.addListener(notifyListeners);
  }

  @override
  R get value => _transform(_source.value);

  @override
  void dispose() {
    _source.removeListener(notifyListeners);
    super.dispose();
  }
}

final class _ZipNotifier<T1, T2> extends ValueNotifier<(T1, T2)> {
  final ValueListenable<T1> a;
  final ValueListenable<T2> b;

  _ZipNotifier._(this.a, this.b) : super((a.value, b.value)) {
    void update() => value = (a.value, b.value);
    a.addListener(update);
    b.addListener(update);
    _cleanup = () {
      a.removeListener(update);
      b.removeListener(update);
    };
  }

  late final void Function() _cleanup;

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}
