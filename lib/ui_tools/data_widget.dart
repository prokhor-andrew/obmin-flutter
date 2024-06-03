// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';

class DataWidget<T> extends StatefulWidget {
  final T Function() init;
  final Widget Function(
    BuildContext context,
    T Function() getState,
    void Function(T newState) setState,
  ) builder;

  const DataWidget({
    super.key,
    required this.init,
    required this.builder,
  });

  @override
  State<DataWidget<T>> createState() => _DataWidgetState<T>();
}

class _DataWidgetState<T> extends State<DataWidget<T>> {
  late T _state;

  @override
  void initState() {
    super.initState();
    _state = widget.init();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      () {
        return _state;
      },
      (newState) {
        setState(() {
          _state = newState;
        });
      },
    );
  }
}
