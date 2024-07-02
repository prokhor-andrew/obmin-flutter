// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/call/call.dart';
import 'package:obmin/call/escapable_recursive_call.dart';
import 'package:obmin/call/result.dart';
import 'package:obmin/optics/affine.dart';
import 'package:obmin/optics/optics_factory.dart';
import 'package:obmin/types/optional.dart';

extension EscapableRecursiveCallOptics on OpticsFactory {
  Affine<EscapableRecursiveCall<Req, Res, Err>, Call<Req, Result<Res, Err>>> escapableRecursiveCallToResultCallAffine<Req, Res, Err>() {
    Optional<Call<Req, Result<Res, Err>>> get(EscapableRecursiveCall<Req, Res, Err> rec) {
      switch (rec.call) {
        case Launched(value: final req):
          return Some(Returned(Failure(req)));
        case Returned(value: final res):
          switch (res) {
            case Launched(value: final req):
              return Some(Launched(req));
            case Returned(value: final res):
              switch (res) {
                case Success(value: final result):
                  return Some(Returned(Success(result)));
                case Failure(value: final error):
                  return get(error);
              }
          }
      }
    }

    Optional<EscapableRecursiveCall<Req, Res, Err>> put(EscapableRecursiveCall<Req, Res, Err> whole, Call<Req, Result<Res, Err>> call) {
      switch (whole.call) {
        case Launched<Err, Call<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>>():
          switch (call) {
            case Launched<Req, Result<Res, Err>>(value: final req):
              return Some(EscapableRecursiveCall(Returned(Launched(req))));
            case Returned<Req, Result<Res, Err>>():
              return None();
          }
        case Returned<Err, Call<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>>(value: final res):
          switch (res) {
            case Launched<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>():
              switch (call) {
                case Launched<Req, Result<Res, Err>>():
                  return None();
                case Returned<Req, Result<Res, Err>>(value: final res):
                  switch (res) {
                    case Success<Res, Err>(value: final result):
                      return Some(EscapableRecursiveCall(Returned(Returned(Success(result)))));
                    case Failure<Res, Err>(value: final error):
                      return Some(EscapableRecursiveCall(Returned(Returned(Failure(EscapableRecursiveCall(Launched(error)))))));
                  }
              }
            case Returned<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>(value: final res):
              switch (res) {
                case Success<Res, EscapableRecursiveCall<Req, Res, Err>>():
                  return None();
                case Failure<Res, EscapableRecursiveCall<Req, Res, Err>>(value: final error):
                  return put(error, call).map((value) {
                    return EscapableRecursiveCall(Returned(Returned(Failure(value))));
                  });
              }
          }
      }
    }

    return Affine(get: get, put: put);
  }

  Affine<EscapableRecursiveCall<Req, Res, Err>, Call<Err, Req>> escapableRecursiveCallToTriggerCallAffine<Req, Res, Err>() {
    Optional<Call<Err, Req>> get(EscapableRecursiveCall<Req, Res, Err> whole) {
      switch (whole.call) {
        case Launched<Err, Call<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>>(value: final value):
          return Some(Launched(value));
        case Returned<Err, Call<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>>(value: final value):
          switch (value) {
            case Launched<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>(value: final value):
              return Some(Returned(value));
            case Returned<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>(value: final value):
              switch (value) {
                case Success<Res, EscapableRecursiveCall<Req, Res, Err>>():
                  return None();
                case Failure<Res, EscapableRecursiveCall<Req, Res, Err>>(value: final value):
                  return get(value);
              }
          }
      }
    }

    Optional<EscapableRecursiveCall<Req, Res, Err>> put(EscapableRecursiveCall<Req, Res, Err> whole, Call<Err, Req> part) {
      switch (whole.call) {
        case Launched<Err, Call<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>>():
          switch (part) {
            case Launched<Err, Req>():
              return None();
            case Returned<Err, Req>(value: final value):
              return Some(EscapableRecursiveCall(Returned(Launched(value))));
          }
        case Returned<Err, Call<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>>(value: final value):
          switch (value) {
            case Launched<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>():
              switch (part) {
                case Launched<Err, Req>(value: final value):
                  return Some(EscapableRecursiveCall(Returned(Returned(Failure(EscapableRecursiveCall(Launched(value)))))));
                case Returned<Err, Req>():
                  return None();
              }
            case Returned<Req, Result<Res, EscapableRecursiveCall<Req, Res, Err>>>(value: final result):
              switch (result) {
                case Success<Res, EscapableRecursiveCall<Req, Res, Err>>():
                  return None();
                case Failure<Res, EscapableRecursiveCall<Req, Res, Err>>(value: final value):
                  return put(value, part).map((value) {
                    return EscapableRecursiveCall(Returned(Returned(Failure(value))));
                  });
              }
          }
      }
    }

    return Affine(get: get, put: put);
  }
}
