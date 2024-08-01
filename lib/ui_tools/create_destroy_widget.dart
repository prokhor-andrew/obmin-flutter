// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';

final class CreateDestroyWidget extends StatefulWidget {
  final void Function() onCreate;
  final void Function() onDestroy;
  final Widget child;

  const CreateDestroyWidget({
    super.key,
    required this.onCreate,
    required this.onDestroy,
    required this.child,
  });

  @override
  State<CreateDestroyWidget> createState() => _CreateDestroyWidgetState();
}

class _CreateDestroyWidgetState extends State<CreateDestroyWidget> {
  @override
  void initState() {
    super.initState();
    widget.onCreate();
  }

  @override
  void dispose() {
    widget.onDestroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
