// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/transformers/bi_preview.dart';
import 'package:obmin/optics/transformers/iso.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/transformers/prism.dart';
import 'package:obmin/optics/transformers/reflector.dart';
import 'package:obmin/optics/readonly/preview.dart';
import 'package:obmin/types/optional.dart';
import 'package:obmin/utils/bool_fold.dart';

final class Result<Res, Err> {
  final bool _isSuccess;
  final Res? _res;
  final Err? _err;

  const Result.success(Res res)
      : _res = res,
        _err = null,
        _isSuccess = true;

  const Result.failure(Err err)
      : _err = err,
        _res = null,
        _isSuccess = false;

  T fold<T>(
      T Function(Res res) ifSuccess,
      T Function(Err err) ifFailure,
      ) {
    return _isSuccess.fold<T>(
          () => ifSuccess(_res!),
          () => ifFailure(_err!),
    );
  }

  @override
  String toString() {
    return fold<String>(
          (res) => "Success<$Res, $Err> { res=$res }",
          (err) => "Failure<$Res, $Err> { err=$err }",
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Result<Res, Err>) return false;

    if (_isSuccess != other._isSuccess) return false;

    if (_isSuccess) {
      return _res == other._res;
    } else {
      return _err == other._err;
    }
  }

  @override
  int get hashCode => _isSuccess ? _res.hashCode : _err.hashCode;

  Result<T, Err> bindRes<T>(Result<T, Err> Function(Res res) function) {
    return fold<Result<T, Err>>(
          (value) => function(value),
      Result<T, Err>.failure,
    );
  }

  Result<T, Err> mapRes<T>(T Function(Res res) function) {
    return bindRes<T>((value) => Result<T, Err>.success(function(value)));
  }

  Result<T, Err> mapResTo<T>(T value) {
    return mapRes<T>((_) => value);
  }

  Result<Res, T> bindErr<T>(Result<Res, T> Function(Err err) function) {
    return fold<Result<Res, T>>(
      Result<Res, T>.success,
          (value) => function(value),
    );
  }

  Result<Res, T> mapErr<T>(T Function(Err err) function) {
    return bindErr<T>((value) => Result<Res, T>.failure(function(value)));
  }

  Result<Res, T> mapErrTo<T>(T value) {
    return mapErr<T>((_) => value);
  }

  Optional<Res> get successOrNone => fold<Optional<Res>>(
        (res) => Optional<Res>.some(res),
        (err) => Optional<Res>.none(),
  );

  Optional<Err> get failureOrNone => fold<Optional<Err>>(
        (res) => Optional<Err>.none(),
        (err) => Optional<Err>.some(err),
  );

  bool get isSuccess => successOrNone.mapTo(true).valueOr(false);

  bool get isFailure => !isSuccess;

  void executeIfSuccess(void Function(Res value) function) {
    fold<void Function()>(
          (value) => () => function(value),
          (_) => () {},
    )();
  }

  void executeIfFailure(void Function(Err value) function) {
    fold<void Function()>(
          (_) => () {},
          (value) => () => function(value),
    )();
  }

  static Eqv<Result<L, R>> eqv<L, R>() => Eqv<Result<L, R>>();

  static Mutator<Result<L, R>, Result<L, R>> reducer<L, R>() => Mutator.reducer<Result<L, R>>();
}

extension ResultObminOpticEqvExtension<Res, Err> on Eqv<Result<Res, Err>> {
  Preview<Result<Res, Err>, Res> get success => Preview<Result<Res, Err>, Res>((whole) => whole.successOrNone);

  Preview<Result<Res, Err>, Err> get failure => Preview<Result<Res, Err>, Err>((whole) => whole.failureOrNone);
}

extension ResultObminOpticGetterExtension<Whole, Res, Err> on Getter<Whole, Result<Res, Err>> {
  Preview<Whole, Res> get success => composeWithPreview(Preview<Result<Res, Err>, Res>((whole) => whole.successOrNone));

  Preview<Whole, Err> get failure => composeWithPreview(Preview<Result<Res, Err>, Err>((whole) => whole.failureOrNone));
}

extension ResultObminOpticPreviewExtension<Whole, Res, Err> on Preview<Whole, Result<Res, Err>> {
  Preview<Whole, Res> get success => compose(Preview<Result<Res, Err>, Res>((whole) => whole.successOrNone));

  Preview<Whole, Err> get failure => compose(Preview<Result<Res, Err>, Err>((whole) => whole.failureOrNone));
}

extension ResultObminOpticFoldExtension<Whole, Res, Err> on Fold<Whole, Result<Res, Err>> {
  Fold<Whole, Res> get success => composeWithPreview(Preview<Result<Res, Err>, Res>((whole) => whole.successOrNone));

  Fold<Whole, Err> get failure => composeWithPreview(Preview<Result<Res, Err>, Err>((whole) => whole.failureOrNone));
}

extension ResultObminOpticMutatorExtension<Whole, Res, Err> on Mutator<Whole, Result<Res, Err>> {
  Mutator<Whole, Res> get success => composeWithPrism(
    Prism<Result<Res, Err>, Res>(
      Preview<Result<Res, Err>, Res>((whole) => whole.successOrNone),
      Getter<Res, Result<Res, Err>>(Result<Res, Err>.success),
    ),
  );

  Mutator<Whole, Err> get failure => composeWithPrism(
    Prism<Result<Res, Err>, Err>(
      Preview<Result<Res, Err>, Err>((whole) => whole.failureOrNone),
      Getter<Err, Result<Res, Err>>(Result<Res, Err>.failure),
    ),
  );
}

extension ResultObminOpticIsoExtension<Whole, Res, Err> on Iso<Whole, Result<Res, Err>> {
  Prism<Whole, Res> get success => composeWithPrism(
    Prism<Result<Res, Err>, Res>(
      Preview<Result<Res, Err>, Res>((whole) => whole.successOrNone),
      Getter<Res, Result<Res, Err>>(Result<Res, Err>.success),
    ),
  );

  Prism<Whole, Err> get failure => composeWithPrism(
    Prism<Result<Res, Err>, Err>(
      Preview<Result<Res, Err>, Err>((whole) => whole.failureOrNone),
      Getter<Err, Result<Res, Err>>(Result<Res, Err>.failure),
    ),
  );
}

extension ResultObminOpticPrismExtension<Whole, Res, Err> on Prism<Whole, Result<Res, Err>> {
  Prism<Whole, Res> get success => compose(
    Prism<Result<Res, Err>, Res>(
      Preview<Result<Res, Err>, Res>((whole) => whole.successOrNone),
      Getter<Res, Result<Res, Err>>(Result<Res, Err>.success),
    ),
  );

  Prism<Whole, Err> get failure => compose(
    Prism<Result<Res, Err>, Err>(
      Preview<Result<Res, Err>, Err>((whole) => whole.failureOrNone),
      Getter<Err, Result<Res, Err>>(Result<Res, Err>.failure),
    ),
  );
}

extension ResultObminOpticReflectorExtension<Whole, Res, Err> on Reflector<Whole, Result<Res, Err>> {
  BiPreview<Whole, Res> get success => composeWithPrism(
    Prism<Result<Res, Err>, Res>(
      Preview<Result<Res, Err>, Res>((whole) => whole.successOrNone),
      Getter<Res, Result<Res, Err>>(Result<Res, Err>.success),
    ),
  );

  BiPreview<Whole, Err> get failure => composeWithPrism(
    Prism<Result<Res, Err>, Err>(
      Preview<Result<Res, Err>, Err>((whole) => whole.failureOrNone),
      Getter<Err, Result<Res, Err>>(Result<Res, Err>.failure),
    ),
  );
}

extension ResultObminOpticBiPreviewExtension<Whole, Res, Err> on BiPreview<Whole, Result<Res, Err>> {
  BiPreview<Whole, Res> get success => composeWithPrism(
    Prism<Result<Res, Err>, Res>(
      Preview<Result<Res, Err>, Res>((whole) => whole.successOrNone),
      Getter<Res, Result<Res, Err>>(Result<Res, Err>.success),
    ),
  );

  BiPreview<Whole, Err> get failure => composeWithPrism(
    Prism<Result<Res, Err>, Err>(
      Preview<Result<Res, Err>, Err>((whole) => whole.failureOrNone),
      Getter<Err, Result<Res, Err>>(Result<Res, Err>.failure),
    ),
  );
}
