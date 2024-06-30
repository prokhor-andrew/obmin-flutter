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
    required Silo<Res> Function(Req req) machine,
  }) {
    return affine.get(state).bind<Silo<Res>>((value) {
      switch (value) {
        case Launched<Req, Res>(req: final req):
          return Some(machine(req));
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

  Set<Silo<State Function(State)>> Function(List<ChamberConfig<State, Req, Res>>) calls<State, Req, Res>(State state) {
    return (list) {
      final Set<Silo<State Function(State)>> result = {};

      for (final config in list) {
        final optionalMachine = MachineFactory.shared.call(
          state: state,
          affine: config.affine,
          machine: config.machine,
        );
        switch (optionalMachine) {
          case None<Silo<State Function(State)>>():
            break;
          case Some<Silo<State Function(State)>>(value: final value):
            result.add(value);
            break;
        }
      }

      return result;
    };
  }
}

final class ChamberConfig<Whole, Req, Res> {
  final Affine<Whole, Call<Req, Res>> affine;
  final Silo<Res> Function(Req req) machine;

  ChamberConfig({
    required this.affine,
    required this.machine,
  });
}
