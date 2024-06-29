// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/a_foundation/types/either.dart';
import 'package:obmin/a_foundation/types/lens.dart';
import 'package:obmin/a_foundation/types/optional.dart';
import 'package:obmin/a_foundation/types/prism.dart';
import 'package:obmin/call/call.dart';
import 'package:obmin/call/escapable_recursive_call.dart';
import 'package:obmin/call/escapable_recursive_call_optics.dart';
import 'package:obmin/call/result.dart';

Prism<Either<LeftScope, RightScope>, Call<Req, Result<Res, Err>>> ScopeToCallPrism<LeftScope, RightScope, Req, Res, Err>({
  required Lens<LeftScope, EscapableRecursiveCall<Req, (), Err>> leftScopeLens,
  required Res Function(RightScope right) mapRightScopeIntoRes,
  required RightScope Function(Res res) mapResIntoRightScope,
}) {
  return Prism(
    get: (whole) {
      switch (whole) {
        case Left<LeftScope, RightScope>(value: final value):
          final escapableRecursiveCall = leftScopeLens.get(value);

          final call = EscapableRecursiveCallToResultCallLens<Req, (), Err>().get(escapableRecursiveCall);

          switch (call) {
            case Launched<Req, Result<(), Err>>(req: final req):
              return Some(Launched(req));
            case Returned<Req, Result<(), Err>>(res: final res):
              switch (res) {
                case Success<(), Err>():
                  return None();
                case Failure<(), Err>(error: final error):
                  return Some(Returned(Failure(error)));
              }
          }

        case Right<LeftScope, RightScope>(value: final value):
          return Some(Returned<Req, Result<Res, Err>>(Success(mapRightScopeIntoRes(value))));
      }
    },
    put: (whole, part) {
      switch (whole) {
        case Left<LeftScope, RightScope>(value: final value):
          switch (part) {
            case Launched<Req, Result<Res, Err>>(req: final req):
              final Call<Req, Result<(), Err>> newPart = Launched(req);

              final currentRecursiveCall = leftScopeLens.get(value);

              final newCurrentRecursiveCall = EscapableRecursiveCallToResultCallLens<Req, (), Err>().put(currentRecursiveCall, newPart);

              return Left(leftScopeLens.put(value, newCurrentRecursiveCall));
            case Returned<Req, Result<Res, Err>>(res: final res):
              switch (res) {
                case Success<Res, Err>(result: final result):
                  return Right(mapResIntoRightScope(result));

                case Failure<Res, Err>(error: final error):
                  final Call<Req, Result<(), Err>> newPart = Returned(Failure(error));

                  final currentRecursiveCall = leftScopeLens.get(value);

                  final newCurrentRecursiveCall = EscapableRecursiveCallToResultCallLens<Req, (), Err>().put(currentRecursiveCall, newPart);

                  return Left(leftScopeLens.put(value, newCurrentRecursiveCall));
              }
          }

        case Right<LeftScope, RightScope>():
          return whole;
      }
    },
  );
}

extension ScopePrismExtension<Whole, LeftScope, RightScope> on Prism<Whole, Either<LeftScope, RightScope>> {
  Prism<Whole, Call<Req, Result<Res, Err>>> zoomIntoScopedCall<Req, Res, Err>({
    required Lens<LeftScope, EscapableRecursiveCall<Req, (), Err>> leftScopeLens,
    required Res Function(RightScope right) mapRightScopeIntoRes,
    required RightScope Function(Res res) mapResIntoRightScope,
  }) {
    return composeWithPrism(
      ScopeToCallPrism(
        leftScopeLens: leftScopeLens,
        mapResIntoRightScope: mapResIntoRightScope,
        mapRightScopeIntoRes: mapRightScopeIntoRes,
      ),
    );
  }
}

extension ScopeLensExtension<Whole, LeftScope, RightScope> on Lens<Whole, Either<LeftScope, RightScope>> {
  Prism<Whole, Call<Req, Result<Res, Err>>> zoomIntoScopedCall<Req, Res, Err>({
    required Lens<LeftScope, EscapableRecursiveCall<Req, (), Err>> leftScopeLens,
    required Res Function(RightScope right) mapRightScopeIntoRes,
    required RightScope Function(Res res) mapResIntoRightScope,
  }) {
    return composeWithPrism(
      ScopeToCallPrism(
        leftScopeLens: leftScopeLens,
        mapResIntoRightScope: mapResIntoRightScope,
        mapRightScopeIntoRes: mapRightScopeIntoRes,
      ),
    );
  }
}
