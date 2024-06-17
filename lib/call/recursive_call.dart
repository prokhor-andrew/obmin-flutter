// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/call/call.dart';

final class RecursiveCall<Req, Res> {
  final Call<Res, Call<Req, RecursiveCall<Req, Res>>> call;

  RecursiveCall(this.call);
}
