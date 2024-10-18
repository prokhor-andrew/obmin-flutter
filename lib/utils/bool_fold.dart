// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:meta/meta.dart';

extension BoolFoldExtension on bool {
  @useResult
  R fold<R>(
    R Function() ifTrue,
    R Function() ifFalse,
  ) {
    if (this) {
      return ifTrue();
    } else {
      return ifFalse();
    }
  }
}
