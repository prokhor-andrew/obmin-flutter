// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

extension ISetFlattenedExtension<T> on ISet<ISet<T>> {
  ISet<T> get flattened {
    ISet<T> result = const ISet.empty();

    for (int i = 0; i < length; i++) {
      for (int j = 0; j < this[i].length; j++) {
        result = result.add(this[i][j]);
      }
    }

    return result;
  }
}
