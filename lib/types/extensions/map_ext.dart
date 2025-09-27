// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/optics/optic.dart';

extension IMapOpticExtension<Key, S, A> on Optic<S, IMap<Key, A>> {
  Optic<S, A> each() {
    return then(Optic.map<Key, A, A>());
  }
}
