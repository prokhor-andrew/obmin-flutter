// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

extension IListFlattenedExtension<T> on IList<IList<T>> {
  IList<T> get iListFlattened {
    IList<T> result = const IList.empty();

    for (int i = 0; i < length; i++) {
      final iItem = this[i];
      for (int j = 0; j < this[i].length; j++) {
        result = result.add(iItem[j]);
      }
    }

    return result;
  }
}
