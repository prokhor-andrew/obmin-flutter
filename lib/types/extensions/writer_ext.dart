// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/writer.dart';

extension WriterOpticExtension<S, A, B> on Optic<S, Writer<A, B>> {
  Optic<S, IList<A>> list() {
    return then(Optic.fromRun((update) {
      return (whole) {
        return Writer(update(whole.list()), whole.value());
      };
    }));
  }

  Optic<S, B> value() {
    return then(Optic.writer<A, B, B>());
  }
}
