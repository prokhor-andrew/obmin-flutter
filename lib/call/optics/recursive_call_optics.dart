// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/call/call.dart';
import 'package:obmin/call/recursive_call.dart';
import 'package:obmin/optics/affine.dart';
import 'package:obmin/optics/optics_factory.dart';
import 'package:obmin/types/optional.dart';

extension RecursiveCallOptics on OpticsFactory {
  Affine<RecursiveCall<Req, Res>, Call<Req, Res>> recursiveCallToResultCallAffine<Req, Res>() {
    Optional<Call<Req, Res>> get(RecursiveCall<Req, Res> rec) {
      switch (rec.call) {
        case Launched(value: final req):
          return Some(Returned(req));
        case Returned(value: final res):
          switch (res) {
            case Launched(value: final req):
              return Some(Launched(req));
            case Returned(value: final res):
              return get(res);
          }
      }
    }

    Optional<RecursiveCall<Req, Res>> put(RecursiveCall<Req, Res> whole, Call<Req, Res> call) {
      switch (whole.call) {
        case Launched():
          switch (call) {
            case Launched(value: final req):
              return Some(RecursiveCall(Returned(Launched(req))));
            case Returned():
              return None();
          }
        case Returned(value: final res):
          switch (res) {
            case Launched():
              switch (call) {
                case Launched():
                  return None();
                case Returned(value: final res):
                  return Some(RecursiveCall(Returned(Returned(RecursiveCall(Launched(res))))));
              }
            case Returned(value: final res):
              return put(res, call).map((value) {
                return RecursiveCall(Returned(Returned(value)));
              });
          }
      }
    }

    return Affine(get: get, put: put);
  }

  Affine<RecursiveCall<Req, Res>, Call<Res, Req>> recursiveCallToTriggerCallAffine<Req, Res>() {
    Optional<Call<Res, Req>> get(RecursiveCall<Req, Res> rec) {
      switch (rec.call) {
        case Launched(value: final req):
          return Some(Launched(req));
        case Returned(value: final res):
          switch (res) {
            case Launched(value: final req):
              return Some(Returned(req));
            case Returned(value: final res):
              return get(res);
          }
      }
    }

    Optional<RecursiveCall<Req, Res>> put(RecursiveCall<Req, Res> whole, Call<Res, Req> call) {
      switch (whole.call) {
        case Launched():
          switch (call) {
            case Launched():
              return None();
            case Returned(value: final res):
              return Some(RecursiveCall(Returned(Launched(res))));
          }
        case Returned(value: final res):
          switch (res) {
            case Launched():
              switch (call) {
                case Launched(value: final req):
                  return Some(RecursiveCall(Returned(Returned(RecursiveCall(Launched(req))))));
                case Returned():
                  return None();
              }
            case Returned(value: final res):
              return put(res, call).map((value) {
                return RecursiveCall(Returned(Returned(value)));
              });
          }
      }
    }

    return Affine(get: get, put: put);
  }
}
