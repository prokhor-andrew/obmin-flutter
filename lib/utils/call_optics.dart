// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/fp/call.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/readonly/eqv.dart';
import 'package:obmin/optics/readonly/fold_set.dart';
import 'package:obmin/optics/readonly/getter.dart';
import 'package:obmin/optics/readonly/preview.dart';

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
  Mutator<Whole, Req> get launched => compose(
        Mutator.prism<Call<Req, Res>, Req>(
          Preview<Call<Req, Res>, Req>((whole) => whole.launchedOrNone),
          Getter<Req, Call<Req, Res>>(Call<Req, Res>.launched),
        ),
      );

  Mutator<Whole, Res> get returned => compose(
        Mutator.prism<Call<Req, Res>, Res>(
          Preview<Call<Req, Res>, Res>((whole) => whole.returnedOrNone),
          Getter<Res, Call<Req, Res>>(Call<Req, Res>.returned),
        ),
      );
}
