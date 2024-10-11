// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/optics/transformers/bi_preview.dart';
import 'package:obmin/optics/transformers/iso.dart';
import 'package:obmin/optics/transformers/prism.dart';
import 'package:obmin/optics/transformers/reflector.dart';
import 'package:obmin/types/optional.dart';
import 'package:obmin/utils/bool_fold.dart';

final class Call<Req, Res> {
  final bool _isLaunched;
  final Req? _req;
  final Res? _res;

  const Call.launched(Req req)
      : _req = req,
        _res = null,
        _isLaunched = true;

  const Call.returned(Res res)
      : _res = res,
        _req = null,
        _isLaunched = false;

  T fold<T>(
    T Function(Req req) ifLaunched,
    T Function(Res res) ifReturned,
  ) {
    return _isLaunched.fold<T>(
      () => ifLaunched(_req!),
      () => ifReturned(_res!),
    );
  }

  @override
  String toString() {
    return fold<String>(
      (req) => "Launched<$Req, $Res> { req=$req }",
      (res) => "Returned<$Req, $Res> { res=$res }",
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Call<Req, Res>) return false;

    if (_isLaunched != other._isLaunched) return false;

    if (_isLaunched) {
      return _req == other._req;
    } else {
      return _res == other._res;
    }
  }

  @override
  int get hashCode => _isLaunched ? _req.hashCode : _res.hashCode;

  Call<T, Res> bindReq<T>(Call<T, Res> Function(Req req) function) {
    return fold<Call<T, Res>>(
      (value) => function(value),
      Call<T, Res>.returned,
    );
  }

  Call<T, Res> mapReq<T>(T Function(Req req) function) {
    return bindReq<T>((value) => Call<T, Res>.launched(function(value)));
  }

  Call<T, Res> mapReqTo<T>(T value) {
    return mapReq<T>((_) => value);
  }

  Call<Req, T> bindRes<T>(Call<Req, T> Function(Res res) function) {
    return fold<Call<Req, T>>(
      Call<Req, T>.launched,
      (value) => function(value),
    );
  }

  Call<Req, T> mapRes<T>(T Function(Res res) function) {
    return bindRes<T>((value) => Call<Req, T>.returned(function(value)));
  }

  Call<Req, T> mapResTo<T>(T value) {
    return mapRes<T>((_) => value);
  }

  Optional<Req> get launchedOrNone => fold<Optional<Req>>(
        (req) => Optional<Req>.some(req),
        (res) => Optional<Req>.none(),
      );

  Optional<Res> get returnedOrNone => fold<Optional<Res>>(
        (req) => Optional<Res>.none(),
        (res) => Optional<Res>.some(res),
      );

  bool get isLaunched => launchedOrNone.mapTo(true).valueOr(false);

  bool get isReturned => !isLaunched;

  void executeIfLaunched(void Function(Req value) function) {
    fold<void Function()>(
      (value) => () => function(value),
      (_) => () {},
    )();
  }

  void executeIfReturned(void Function(Res value) function) {
    fold<void Function()>(
      (_) => () {},
      (value) => () => function(value),
    )();
  }

  static Eqv<Call<L, R>> eqv<L, R>() => Eqv<Call<L, R>>();

  static Mutator<Call<L, R>, Call<L, R>> reducer<L, R>() => Mutator.reducer<Call<L, R>>();
}

extension CallObminOpticEqvExtension<Req, Res> on Eqv<Call<Req, Res>> {
  Preview<Call<Req, Res>, Req> get launched => Preview<Call<Req, Res>, Req>((whole) => whole.launchedOrNone);

  Preview<Call<Req, Res>, Res> get returned => Preview<Call<Req, Res>, Res>((whole) => whole.returnedOrNone);
}

extension CallObminOpticGetterExtension<Whole, Req, Res> on Getter<Whole, Call<Req, Res>> {
  Preview<Whole, Req> get launched => composeWithPreview(Preview<Call<Req, Res>, Req>((whole) => whole.launchedOrNone));

  Preview<Whole, Res> get returned => composeWithPreview(Preview<Call<Req, Res>, Res>((whole) => whole.returnedOrNone));
}

extension CallObminOpticPreviewExtension<Whole, Req, Res> on Preview<Whole, Call<Req, Res>> {
  Preview<Whole, Req> get launched => compose(Preview<Call<Req, Res>, Req>((whole) => whole.launchedOrNone));

  Preview<Whole, Res> get returned => compose(Preview<Call<Req, Res>, Res>((whole) => whole.returnedOrNone));
}

extension CallObminOpticFoldSetExtension<Whole, Req, Res> on FoldSet<Whole, Call<Req, Res>> {
  FoldSet<Whole, Req> get launched => composeWithPreview(Preview<Call<Req, Res>, Req>((whole) => whole.launchedOrNone));

  FoldSet<Whole, Res> get returned => composeWithPreview(Preview<Call<Req, Res>, Res>((whole) => whole.returnedOrNone));
}


extension CallObminOpticMutatorExtension<Whole, Req, Res> on Mutator<Whole, Call<Req, Res>> {
  Mutator<Whole, Req> get launched => composeWithPrism(
        Prism<Call<Req, Res>, Req>(
          Preview<Call<Req, Res>, Req>((whole) => whole.launchedOrNone),
          Getter<Req, Call<Req, Res>>(Call<Req, Res>.launched),
        ),
      );

  Mutator<Whole, Res> get returned => composeWithPrism(
        Prism<Call<Req, Res>, Res>(
          Preview<Call<Req, Res>, Res>((whole) => whole.returnedOrNone),
          Getter<Res, Call<Req, Res>>(Call<Req, Res>.returned),
        ),
      );
}

extension CallObminOpticIsoExtension<Whole, Req, Res> on Iso<Whole, Call<Req, Res>> {
  Prism<Whole, Req> get launched => composeWithPrism(
        Prism<Call<Req, Res>, Req>(
          Preview<Call<Req, Res>, Req>((whole) => whole.launchedOrNone),
          Getter<Req, Call<Req, Res>>(Call<Req, Res>.launched),
        ),
      );

  Prism<Whole, Res> get returned => composeWithPrism(
        Prism<Call<Req, Res>, Res>(
          Preview<Call<Req, Res>, Res>((whole) => whole.returnedOrNone),
          Getter<Res, Call<Req, Res>>(Call<Req, Res>.returned),
        ),
      );
}

extension CallObminOpticPrismExtension<Whole, Req, Res> on Prism<Whole, Call<Req, Res>> {
  Prism<Whole, Req> get launched => compose(
        Prism<Call<Req, Res>, Req>(
          Preview<Call<Req, Res>, Req>((whole) => whole.launchedOrNone),
          Getter<Req, Call<Req, Res>>(Call<Req, Res>.launched),
        ),
      );

  Prism<Whole, Res> get returned => compose(
        Prism<Call<Req, Res>, Res>(
          Preview<Call<Req, Res>, Res>((whole) => whole.returnedOrNone),
          Getter<Res, Call<Req, Res>>(Call<Req, Res>.returned),
        ),
      );
}

extension CallObminOpticReflectorExtension<Whole, Req, Res> on Reflector<Whole, Call<Req, Res>> {
  BiPreview<Whole, Req> get launched => composeWithPrism(
        Prism<Call<Req, Res>, Req>(
          Preview<Call<Req, Res>, Req>((whole) => whole.launchedOrNone),
          Getter<Req, Call<Req, Res>>(Call<Req, Res>.launched),
        ),
      );

  BiPreview<Whole, Res> get returned => composeWithPrism(
        Prism<Call<Req, Res>, Res>(
          Preview<Call<Req, Res>, Res>((whole) => whole.returnedOrNone),
          Getter<Res, Call<Req, Res>>(Call<Req, Res>.returned),
        ),
      );
}

extension CallObminOpticBiPreviewExtension<Whole, Req, Res> on BiPreview<Whole, Call<Req, Res>> {
  BiPreview<Whole, Req> get launched => composeWithPrism(
        Prism<Call<Req, Res>, Req>(
          Preview<Call<Req, Res>, Req>((whole) => whole.launchedOrNone),
          Getter<Req, Call<Req, Res>>(Call<Req, Res>.launched),
        ),
      );

  BiPreview<Whole, Res> get returned => composeWithPrism(
        Prism<Call<Req, Res>, Res>(
          Preview<Call<Req, Res>, Res>((whole) => whole.returnedOrNone),
          Getter<Res, Call<Req, Res>>(Call<Req, Res>.returned),
        ),
      );
}
