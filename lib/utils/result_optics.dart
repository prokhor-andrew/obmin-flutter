// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/fp/result.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

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

extension ResultObminOpticFoldSetExtension<Whole, Res, Err> on FoldSet<Whole, Result<Res, Err>> {
  FoldSet<Whole, Res> get success => composeWithPreview(Preview<Result<Res, Err>, Res>((whole) => whole.successOrNone));

  FoldSet<Whole, Err> get failure => composeWithPreview(Preview<Result<Res, Err>, Err>((whole) => whole.failureOrNone));
}

extension ResultObminOpticMutatorExtension<Whole, Res, Err> on Mutator<Whole, Result<Res, Err>> {
  Mutator<Whole, Res> get success => compose(
        Mutator.prism<Result<Res, Err>, Res>(
          Preview<Result<Res, Err>, Res>((whole) => whole.successOrNone),
          Getter<Res, Result<Res, Err>>(Result<Res, Err>.success),
        ),
      );

  Mutator<Whole, Err> get failure => compose(
        Mutator.prism<Result<Res, Err>, Err>(
          Preview<Result<Res, Err>, Err>((whole) => whole.failureOrNone),
          Getter<Err, Result<Res, Err>>(Result<Res, Err>.failure),
        ),
      );
}
