// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/poly_optic.dart';

typedef Optic<Whole, Part> = PolyOptic<Whole, Whole, Part, Part>;
