// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/logger.dart';

extension LoggerOpticExtension<S, A> on Optic<S, Logger<A>> {
  Optic<S, A> value() {
    return then(Optic.logger<A, A>());
  }
}
