// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';

final class KeyboardContainer extends StatelessWidget {
  final double horSpacing;
  final double verSpacing;
  final List<Widget> children;

  const KeyboardContainer({
    super.key,
    this.horSpacing = 16,
    this.verSpacing = 16,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> result = [];
    for (final item in children) {
      result.add(SizedBox(height: verSpacing));
      result.add(item);
    }

    result.add(SizedBox(height: verSpacing));

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result,
            ),
          ),
        ),
      ],
    );
  }
}
