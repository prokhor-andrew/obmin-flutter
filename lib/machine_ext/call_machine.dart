// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/machine/machine_factory.dart';
import 'package:obmin/machine_ext/silo_machine.dart';
import 'package:obmin/machine_ext/map_output_machine.dart';
import 'package:obmin/call/call.dart';
import 'package:obmin/optics/affine.dart';
import 'package:obmin/types/optional.dart';

extension CallMachine on MachineFactory {
  Optional<Silo<Optional<Whole> Function(Whole)>> call<Whole, Req, Res>({
    required Whole state,
    required Affine<Whole, Call<Req, Res>> affine,
    required Silo<Res> Function(Req req) silo,
  }) {
    return affine.get(state).bind<Silo<Res>>((call) {
      return call.asEither().mapRightTo(()).asOptional().map(silo);
    }).map((machine) {
      return machine.mapOutput((output) {
        return (Whole whole) {
          return affine.put(whole, Returned(output));
        };
      });
    });
  }
}