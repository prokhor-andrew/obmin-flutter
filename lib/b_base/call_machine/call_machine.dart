// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/machine_factory.dart';
import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/a_foundation/types/prism.dart';
import 'package:obmin/b_base/chamber_machine/silo_machine.dart';
import 'package:obmin/call/call.dart';

extension FeatureMachine on MachineFactory {
  Optional<Silo<Whole Function(Whole)>> call<Whole, Req, Res>({
    required Whole state,
    required Prism<Whole, Call<Req, Res>> prism,
    required Silo<Res> Function(Req req) machine,
  }) {
    return prism.get(state).bind((value) {
      switch (value) {
        case Launched<Req, Res>(req: final req):
          return Some(machine(req));
        case Returned<Req, Res>():
          return None();
      }
    }).map((machine) {
      return machine.mapOutput((output) {
        return (Whole whole) {
          return output.map((value) {
            return prism.put(whole, Returned(value));
          });
        };
      });
    });
  }
}
