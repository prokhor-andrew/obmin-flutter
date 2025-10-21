// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:obmin/obmin.dart';

final class ValueNotifierHolder<T> extends InheritedWidget {
  final ValueListenable<T> _listenable;
  final void Function(Endo<T>) _callback;

  const ValueNotifierHolder._({
    required super.child,
    required ValueListenable<T> listenable,
    required void Function(Endo<T>) callback,
    //
  })  : _listenable = listenable,
        _callback = callback;

  static Widget create<T>(
    ValueListenable<(T, Option<void Function(Endo<T> transition)>)> listenable, {
    required Widget child,
    //
  }) {
    return ValueListenableBuilder(
      valueListenable: listenable,
      builder: (context, value, _) {
        final callbackOrNone = value.$2;
        return callbackOrNone.match(SizedBox.shrink, (callback) {
          return ValueNotifierHolder._(listenable: listenable.map((value) => value.$1), callback: callback, child: child);
        });
      },
    );
  }

  static ValueNotifierHolder<T> _of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ValueNotifierHolder<T>>()!;
  }

  @override
  bool updateShouldNotify(old) => false;
}

extension ContextExtension on BuildContext {
  void Function(Endo<T>) getCallback<T>() {
    return ValueNotifierHolder._of<T>(this)._callback;
  }

  ValueListenable<T> getListenable<T>() {
    return ValueNotifierHolder._of<T>(this)._listenable;
  }
}

extension _MapValueListenable<T> on ValueListenable<T> {
  ValueListenable<R> map<R>(R Function(T value) transform) {
    return _MappedValueListenable(this, transform);
  }
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
