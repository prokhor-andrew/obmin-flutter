// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:build/build.dart';
import 'package:obmin/generators/optic_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder opticGeneratorFactory(BuilderOptions options) => SharedPartBuilder(
      [OpticGenerator()],
      'optic',
    );
