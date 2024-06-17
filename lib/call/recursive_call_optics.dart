// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/lens.dart';
import 'package:obmin/call/call.dart';
import 'package:obmin/call/recursive_call.dart';

Lens<RecursiveCall<Req, Res>, Call<Req, Res>> RecursiveCallToCallLens<Req, Res>() {
  Call<Req, Res> get(RecursiveCall<Req, Res> rec) {
    switch (rec.call) {
      case Launched(req: final req):
        return Returned(req);
      case Returned(res: final res):
        switch (res) {
          case Launched(req: final req):
            return Launched(req);
          case Returned(res: final res):
            return get(res);
        }
    }
  }

  RecursiveCall<Req, Res> put(RecursiveCall<Req, Res> whole, Call<Req, Res> call) {
    switch (whole.call) {
      case Launched():
        switch (call) {
          case Launched(req: final req):
            return RecursiveCall(Returned(Launched(req)));
          case Returned(res: final res):
            return RecursiveCall(Launched(res));
        }
      case Returned(res: final res):
        switch (res) {
          case Launched():
            switch (call) {
              case Launched(req: final req):
                return RecursiveCall(Returned(Launched(req)));
              case Returned(res: final res):
                return RecursiveCall(Returned(Returned(RecursiveCall(Launched(res)))));
            }
          case Returned(res: final res):
            return RecursiveCall(Returned(Returned(put(res, call))));
        }
    }
  }

  return Lens(get: get, put: put);
}
