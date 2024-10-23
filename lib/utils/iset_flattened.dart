// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

extension ISetFlattenedExtension<T> on ISet<ISet<T>> {
  ISet<T> get iSetFlattened {
    ISet<T> result = const ISet.empty();

    forEach((set) {
      set.forEach((e) {
        result = result.add(e);
      });
    });

    return result;
  }
}
