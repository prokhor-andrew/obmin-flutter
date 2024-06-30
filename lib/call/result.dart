// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/either.dart';

typedef Result<Res, Err> = Either<Res, Err>;
typedef Success<Res, Err> = Left<Res, Err>;
typedef Failure<Res, Err> = Right<Res, Err>;
