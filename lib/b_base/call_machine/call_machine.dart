// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/machine_factory.dart';
import 'package:obmin/a_foundation/types/optics/affine.dart';
import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/b_base/chamber_machine/silo_machine.dart';
import 'package:obmin/b_base/map_machine/map_output_machine.dart';
import 'package:obmin/call/call.dart';

extension CallMachine on MachineFactory {
  Optional<Silo<Whole Function(Whole)>> call<Whole, Req, Res>({
    required Whole state,
    required Affine<Whole, Call<Req, Res>> affine,
    required Silo<Res> Function(Req req) silo,
  }) {
    return affine.get(state).bind<Silo<Res>>((value) {
      switch (value) {
        case Launched<Req, Res>(req: final req):
          return Some(silo(req));
        case Returned<Req, Res>():
          return None();
      }
    }).map((machine) {
      return machine.mapOutput((output) {
        return (Whole whole) {
          return affine.put(whole, Returned(output)).valueOr(whole);
        };
      });
    });
  }
}