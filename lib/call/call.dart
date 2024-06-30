// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/either.dart';

typedef Call<Req, Res> = Either<Req, Res>;
typedef Launched<Req, Res> = Left<Req, Res>;
typedef Returned<Req, Res> = Right<Req, Res>;
