// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/call/call.dart';
import 'package:obmin/call/result.dart';

final class EscapableRecursiveCall<Req, Res, Err> {
  final Call<Err, Call<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>> call;

  EscapableRecursiveCall(this.call);
}
