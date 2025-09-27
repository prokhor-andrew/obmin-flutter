// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/arrows/path_arrow.dart';
import 'package:obmin/optics/optic.dart';
import 'package:obmin/types/flist.dart';

extension FListOpticExtension<S, A> on Optic<S, FList<A>> {
  Optic<S, A> each() {
    return then(Optic.flist<A>());
  }

  Optic<S, A> head() {
    return then(Optic.fromRun((update) {
      return (whole) {
        return FList(update(whole.head()), whole.tail());
      };
    }));
  }

  Optic<S, IList<A>> tail() {
    return then(Optic.fromRun((update) {
      return (whole) {
        return FList(whole.head(), update(whole.tail()));
      };
    }));
  }
}

extension FListPathArrowExtension<State, Whole, A> on PathArrow<State, Whole, FList<A>> {
  PathArrow<State, Whole, A> each() {
    return then(PathArrow.flist<State, A>());
  }

  PathArrow<State, Whole, A> head() {
    return then(PathArrow.fromRun((tuple) {
      final (state, flist) = tuple;
      return {FList.of("head"): (state, flist.head())}.lock;
    }));
  }

  PathArrow<State, Whole, IList<A>> tail() {
    return then(PathArrow.fromRun((tuple) {
      final (state, flist) = tuple;
      return {FList.of("tail"): (state, flist.tail())}.lock;
    }));
  }
}
