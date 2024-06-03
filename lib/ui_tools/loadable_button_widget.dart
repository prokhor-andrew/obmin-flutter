// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';

class LoadableButtonWidget extends StatelessWidget {
  final double height;
  final double width;
  final double indicatorHeight;
  final double indicatorWidth;
  final bool isLoading;
  final String title;
  final void Function()? onPressed;

  const LoadableButtonWidget({
    super.key,
    required this.title,
    this.indicatorHeight = 24,
    this.indicatorWidth = 24,
    this.height = 48,
    this.width = double.infinity,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: MaterialButton(
        onPressed: isLoading ? null : onPressed,
        textColor: Theme.of(context).colorScheme.onPrimary,
        color: Theme.of(context).colorScheme.primary,
        disabledColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        child: isLoading
            ? SizedBox(
                height: indicatorHeight,
                width: indicatorWidth,
                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary),
              )
            : Text(title),
      ),
    );
  }
}
