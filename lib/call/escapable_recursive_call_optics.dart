// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/lens.dart';
import 'package:obmin/a_foundation/types/prism.dart';
import 'package:obmin/call/call.dart';
import 'package:obmin/call/escapable_recursive_call.dart';
import 'package:obmin/call/result.dart';

Lens<EscapableRecursiveCall<Req, Res, Err>, Call<Req, Result<Res, Err>>> EscapableRecursiveCallToCallLens<Req, Res, Err>() {
  Call<Req, Result<Res, Err>> get(EscapableRecursiveCall<Req, Res, Err> rec) {
    switch (rec.call) {
      case Launched(req: final req):
        return Returned(Failure(req));
      case Returned(res: final res):
        switch (res) {
          case Launched(req: final req):
            return Launched(req);
          case Returned(res: final res):
            switch (res) {
              case Success(result: final result):
                return Returned(Success(result));
              case Failure(error: final error):
                return get(error);
            }
        }
    }
  }

  EscapableRecursiveCall<Req, Res, Err> put(EscapableRecursiveCall<Req, Res, Err> whole, Call<Req, Result<Res, Err>> call) {
    switch (whole.call) {
      case Launched<Err, Call<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>>():
        switch (call) {
          case Launched<Req, Result<Res, Err>>(req: final req):
            return EscapableRecursiveCall(Returned(Launched(req)));
          case Returned<Req, Result<Res, Err>>():
            return whole; // guarded, cause we cant go from "awaiting for trigger" into result state immediately
        }
      case Returned<Err, Call<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>>(res: final res):
        switch (res) {
          case Launched<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>():
            switch (call) {
              case Launched<Req, Result<Res, Err>>():
                return whole;
              case Returned<Req, Result<Res, Err>>(res: final res):
                switch (res) {
                  case Success<Res, Err>(result: final result):
                    return EscapableRecursiveCall(Returned(Returned(Success(result))));
                  case Failure<Res, Err>(error: final error):
                    return EscapableRecursiveCall(Returned(Returned(Failure(EscapableRecursiveCall(Launched(error))))));
                }
            }
          case Returned<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>(res: final res):
            switch (res) {
              case Success<Res, EscapableRecursiveCall<Req, Res, Err>>():
                return whole; // guarded, we cant reach any other state when we reached success cause we "escaped"
              case Failure<Res, EscapableRecursiveCall<Req, Res, Err>>(error: final error):
                return EscapableRecursiveCall(Returned(Returned(Failure(put(error, call)))));
            }
        }
    }
  }

  return Lens(get: get, put: put);
}

extension EscapableRecursiveCallLensExtension<Whole, Req, Res, Err> on Lens<Whole, EscapableRecursiveCall<Req, Res, Err>> {
  Lens<Whole, Call<Req, Result<Res, Err>>> zoomIntoCall() {
    return composeWithLens(EscapableRecursiveCallToCallLens<Req, Res, Err>());
  }
}

extension EscapableRecursiveCallPrismExtension<Whole, Req, Res, Err> on Prism<Whole, EscapableRecursiveCall<Req, Res, Err>> {
  Prism<Whole, Call<Req, Result<Res, Err>>> zoomIntoCall() {
    return composeWithLens(EscapableRecursiveCallToCallLens<Req, Res, Err>());
  }
}
