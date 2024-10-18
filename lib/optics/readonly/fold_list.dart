// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/fp/product.dart';

typedef FoldList<Whole, Part> = FoldSet<Whole, Product<int, Part>>;
