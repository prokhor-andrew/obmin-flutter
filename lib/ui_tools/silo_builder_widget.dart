// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/channel/channel_lib.dart';
import 'package:obmin/fp/optional.dart';
import 'package:obmin/machine/machine.dart';
import 'package:obmin/machine_ext/silo_machine.dart';

extension SiloBuilderWidgetExtension<T> on Silo<T> {
  Widget build(
    Widget Function(BuildContext context, Optional<T> state) builder, [
    ChannelBufferStrategy<T>? bufferStrategy,
  ]) {
    return SiloBuilderWidget(
      silo: this,
      builder: builder,
      bufferStrategy: bufferStrategy,
    );
  }
}

final class SiloBuilderWidget<T> extends StatefulWidget {
  final Silo<T> silo;
  final Widget Function(BuildContext context, Optional<T> state) builder;
  final ChannelBufferStrategy<T>? bufferStrategy;

  const SiloBuilderWidget({
    super.key,
    required this.silo,
    required this.builder,
    this.bufferStrategy,
  });

  @override
  State<SiloBuilderWidget<T>> createState() => _SiloBuilderWidgetState<T>();
}

final class _SiloBuilderWidgetState<T> extends State<SiloBuilderWidget<T>> {
  Optional<T> _state = const Optional.none();

  Process<Never>? _process;

  @override
  void initState() {
    super.initState();
    _process = widget.silo.listen(
      onConsume: (value) async {
        if (mounted) {
          setState(() {
            _state = Optional.some(value);
          });
        }
      },
      bufferStrategy: widget.bufferStrategy,
    );
  }

  @override
  void dispose() {
    _process?.cancel();
    _process = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state);
  }
}
