// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/optics/eqv.dart';
import 'package:obmin/optics/fold.dart';
import 'package:obmin/optics/getter.dart';
import 'package:obmin/optics/mutable/bi_preview.dart';
import 'package:obmin/optics/mutable/iso.dart';
import 'package:obmin/optics/mutable/mutator.dart';
import 'package:obmin/optics/mutable/prism.dart';
import 'package:obmin/optics/mutable/reflector.dart';
import 'package:obmin/optics/preview.dart';
import 'package:obmin/types/optional.dart';

sealed class Call<Req, Res> {
  const Call();

  static Eqv<Call<L, R>> eqv<L, R>() => Eqv<Call<L, R>>();

  static Mutator<Call<L, R>, Call<L, R>> setter<L, R>() => Mutator.setter<Call<L, R>>();

  T fold<T>(
    T Function(Req req) ifLaunched,
    T Function(Res res) ifReturned,
  ) {
    return switch (this) {
      Launched<Req, Res>(req: final req) => ifLaunched(req),
      Returned<Req, Res>(res: final res) => ifReturned(res),
    };
  }

  Call<T, Res> bindReq<T>(Call<T, Res> Function(Req req) function) {
    return fold<Call<T, Res>>(
      (value) => function(value),
      Returned.new,
    );
  }

  Call<Req, T> bindRes<T>(Call<Req, T> Function(Res res) function) {
    return fold<Call<Req, T>>(
      Launched.new,
      (value) => function(value),
    );
  }

  Call<T, Res> mapReq<T>(T Function(Req req) function) {
    return fold<Call<T, Res>>(
      (value) => Launched(function(value)),
      Returned.new,
    );
  }

  Call<Req, T> mapRes<T>(T Function(Res res) function) {
    return fold<Call<Req, T>>(
      Launched.new,
      (value) => Returned(function(value)),
    );
  }

  @override
  String toString() {
    switch (this) {
      case Launched<Req, Res>(req: var req):
        return "Launched<$Req, $Res> { req=$req }";
      case Returned<Req, Res>(res: var res):
        return "Returned<$Req, $Res> { res=$res }";
    }
  }
}

final class Launched<Req, Res> extends Call<Req, Res> {
  final Req req;

  const Launched(this.req);

  static Eqv<Launched<Req, Res>> eqv<Req, Res>() => Eqv<Launched<Req, Res>>();

  static Mutator<Launched<Req, Res>, Launched<Req, Res>> setter<Req, Res>() => Mutator.setter<Launched<Req, Res>>();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Launched<Req, Res> && other.req == req;
  }

  @override
  int get hashCode => req.hashCode;
}

final class Returned<Req, Res> extends Call<Req, Res> {
  final Res res;

  const Returned(this.res);

  static Eqv<Returned<Req, Res>> eqv<Req, Res>() => Eqv<Returned<Req, Res>>();

  static Mutator<Returned<Req, Res>, Returned<Req, Res>> setter<Req, Res>() => Mutator.setter<Returned<Req, Res>>();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Returned<Req, Res> && other.res == res;
  }

  @override
  int get hashCode => res.hashCode;
}

extension LaunchedObminOpticEqvExtension<Req, Res> on Eqv<Launched<Req, Res>> {
  Getter<Launched<Req, Res>, Req> get req => asGetter().req;
}

extension LaunchedObminOpticGetterExtension<Whole, Req, Res> on Getter<Whole, Launched<Req, Res>> {
  Getter<Whole, Req> get req => compose(Getter<Launched<Req, Res>, Req>((whole) => whole.req));
}

extension LaunchedObminOpticPreviewExtension<Whole, Req, Res> on Preview<Whole, Launched<Req, Res>> {
  Preview<Whole, Req> get req => composeWithGetter(Getter<Launched<Req, Res>, Req>((whole) => whole.req));
}

extension LaunchedObminOpticFoldExtension<Whole, Req, Res> on Fold<Whole, Launched<Req, Res>> {
  Fold<Whole, Req> get req => composeWithGetter(Getter<Launched<Req, Res>, Req>((whole) => whole.req));
}

extension LaunchedObminOpticMutatorExtension<Whole, Req, Res> on Mutator<Whole, Launched<Req, Res>> {
  Mutator<Whole, Req> get req => compose(
        Mutator.lens<Launched<Req, Res>, Req>(
          Getter<Launched<Req, Res>, Req>((whole) => whole.req),
          (whole, part) => Launched(part),
        ),
      );
}

extension LaunchedObminOpticIsoExtension<Whole, Req, Res> on Iso<Whole, Launched<Req, Res>> {
  Mutator<Whole, Req> get req => asMutator().compose(
        Mutator.lens<Launched<Req, Res>, Req>(
          Getter<Launched<Req, Res>, Req>((whole) => whole.req),
          (whole, part) => Launched(part),
        ),
      );
}

extension LaunchedObminOpticPrismExtension<Whole, Req, Res> on Prism<Whole, Launched<Req, Res>> {
  Mutator<Whole, Req> get req => asMutator().compose(
        Mutator.lens<Launched<Req, Res>, Req>(
          Getter<Launched<Req, Res>, Req>((whole) => whole.req),
          (whole, part) => Launched(part),
        ),
      );
}

extension LaunchedObminOpticReflectorExtension<Whole, Req, Res> on Reflector<Whole, Launched<Req, Res>> {
  Mutator<Whole, Req> get req => asMutator().compose(
        Mutator.lens<Launched<Req, Res>, Req>(
          Getter<Launched<Req, Res>, Req>((whole) => whole.req),
          (whole, part) => Launched(part),
        ),
      );
}

extension LaunchedObminOpticBiPreviewExtension<Whole, Req, Res> on BiPreview<Whole, Launched<Req, Res>> {
  Mutator<Whole, Req> get req => asMutator().compose(
        Mutator.lens<Launched<Req, Res>, Req>(
          Getter<Launched<Req, Res>, Req>((whole) => whole.req),
          (whole, part) => Launched(part),
        ),
      );
}

extension ReturnedObminOpticEqvExtension<Req, Res> on Eqv<Returned<Req, Res>> {
  Getter<Returned<Req, Res>, Res> get res => asGetter().res;
}

extension ReturnedObminOpticGetterExtension<Whole, Req, Res> on Getter<Whole, Returned<Req, Res>> {
  Getter<Whole, Res> get res => compose(Getter<Returned<Req, Res>, Res>((whole) => whole.res));
}

extension ReturnedObminOpticPreviewExtension<Whole, Req, Res> on Preview<Whole, Returned<Req, Res>> {
  Preview<Whole, Res> get res => composeWithGetter(Getter<Returned<Req, Res>, Res>((whole) => whole.res));
}

extension ReturnedObminOpticFoldExtension<Whole, Req, Res> on Fold<Whole, Returned<Req, Res>> {
  Fold<Whole, Res> get res => composeWithGetter(Getter<Returned<Req, Res>, Res>((whole) => whole.res));
}

extension ReturnedObminOpticMutatorExtension<Whole, Req, Res> on Mutator<Whole, Returned<Req, Res>> {
  Mutator<Whole, Res> get res => compose(
        Mutator.lens<Returned<Req, Res>, Res>(
          Getter<Returned<Req, Res>, Res>((whole) => whole.res),
          (whole, part) => Returned(part),
        ),
      );
}

extension ReturnedObminOpticIsoExtension<Whole, Req, Res> on Iso<Whole, Returned<Req, Res>> {
  Mutator<Whole, Res> get res => asMutator().compose(
        Mutator.lens<Returned<Req, Res>, Res>(
          Getter<Returned<Req, Res>, Res>((whole) => whole.res),
          (whole, part) => Returned(part),
        ),
      );
}

extension ReturnedObminOpticPrismExtension<Whole, Req, Res> on Prism<Whole, Returned<Req, Res>> {
  Mutator<Whole, Res> get res => asMutator().compose(
        Mutator.lens<Returned<Req, Res>, Res>(
          Getter<Returned<Req, Res>, Res>((whole) => whole.res),
          (whole, part) => Returned(part),
        ),
      );
}

extension ReturnedObminOpticReflectorExtension<Whole, Req, Res> on Reflector<Whole, Returned<Req, Res>> {
  Mutator<Whole, Res> get res => asMutator().compose(
        Mutator.lens<Returned<Req, Res>, Res>(
          Getter<Returned<Req, Res>, Res>((whole) => whole.res),
          (whole, part) => Returned(part),
        ),
      );
}

extension ReturnedObminOpticBiPreviewExtension<Whole, Req, Res> on BiPreview<Whole, Returned<Req, Res>> {
  Mutator<Whole, Res> get res => asMutator().compose(
        Mutator.lens<Returned<Req, Res>, Res>(
          Getter<Returned<Req, Res>, Res>((whole) => whole.res),
          (whole, part) => Returned(part),
        ),
      );
}

extension CallObminOpticToolMethodsExtension<Req, Res> on Call<Req, Res> {
  Call<Req, Res> mapLaunched(Launched<Req, Res> Function(Launched<Req, Res> value) function) {
    return fold<Call<Req, Res>>(
      ifLaunched: function,
      ifReturned: (val) => val,
    );
  }

  Call<Req, Res> mapLaunchedTo(Launched<Req, Res> value) {
    return mapLaunched((_) => value);
  }

  Call<Req, Res> bindLaunched(Call<Req, Res> Function(Launched<Req, Res> value) function) {
    return fold<Call<Req, Res>>(
      ifLaunched: function,
      ifReturned: (val) => val,
    );
  }

  Optional<Launched<Req, Res>> get launchedOrNone => fold<Optional<Launched<Req, Res>>>(
        ifLaunched: Some.new,
        ifReturned: (_) => const None(),
      );

  void executeIfLaunched(void Function(Launched<Req, Res> value) function) {
    fold<void Function()>(
      ifLaunched: (value) => () => function(value),
      ifReturned: (_) => () {},
    )();
  }

  Call<Req, Res> mapReturned(Returned<Req, Res> Function(Returned<Req, Res> value) function) {
    return fold<Call<Req, Res>>(
      ifLaunched: (val) => val,
      ifReturned: function,
    );
  }

  Call<Req, Res> mapReturnedTo(Returned<Req, Res> value) {
    return mapReturned((_) => value);
  }

  Call<Req, Res> bindReturned(Call<Req, Res> Function(Returned<Req, Res> value) function) {
    return fold<Call<Req, Res>>(
      ifLaunched: (val) => val,
      ifReturned: function,
    );
  }

  Optional<Returned<Req, Res>> get returnedOrNone => fold<Optional<Returned<Req, Res>>>(
        ifLaunched: (_) => const None(),
        ifReturned: Some.new,
      );

  void executeIfReturned(void Function(Returned<Req, Res> value) function) {
    fold<void Function()>(
      ifLaunched: (_) => () {},
      ifReturned: (value) => () => function(value),
    )();
  }

  R fold<R>({
    required R Function(Launched<Req, Res> value) ifLaunched,
    required R Function(Returned<Req, Res> value) ifReturned,
  }) {
    final value = this;
    return switch (value) {
      Launched<Req, Res>() => ifLaunched(value),
      Returned<Req, Res>() => ifReturned(value),
    };
  }
}

extension CallObminOpticEqvExtension<Req, Res> on Eqv<Call<Req, Res>> {
  Preview<Call<Req, Res>, Launched<Req, Res>> get launched => Preview<Call<Req, Res>, Launched<Req, Res>>((whole) => whole.launchedOrNone);

  Preview<Call<Req, Res>, Returned<Req, Res>> get returned => Preview<Call<Req, Res>, Returned<Req, Res>>((whole) => whole.returnedOrNone);
}

extension CallObminOpticGetterExtension<Whole, Req, Res> on Getter<Whole, Call<Req, Res>> {
  Preview<Whole, Launched<Req, Res>> get launched => composeWithPreview(Preview<Call<Req, Res>, Launched<Req, Res>>((whole) => whole.launchedOrNone));

  Preview<Whole, Returned<Req, Res>> get returned => composeWithPreview(Preview<Call<Req, Res>, Returned<Req, Res>>((whole) => whole.returnedOrNone));
}

extension CallObminOpticPreviewExtension<Whole, Req, Res> on Preview<Whole, Call<Req, Res>> {
  Preview<Whole, Launched<Req, Res>> get launched => compose(Preview<Call<Req, Res>, Launched<Req, Res>>((whole) => whole.launchedOrNone));

  Preview<Whole, Returned<Req, Res>> get returned => compose(Preview<Call<Req, Res>, Returned<Req, Res>>((whole) => whole.returnedOrNone));
}

extension CallObminOpticFoldExtension<Whole, Req, Res> on Fold<Whole, Call<Req, Res>> {
  Fold<Whole, Launched<Req, Res>> get launched => composeWithPreview(Preview<Call<Req, Res>, Launched<Req, Res>>((whole) => whole.launchedOrNone));

  Fold<Whole, Returned<Req, Res>> get returned => composeWithPreview(Preview<Call<Req, Res>, Returned<Req, Res>>((whole) => whole.returnedOrNone));
}

extension CallObminOpticMutatorExtension<Whole, Req, Res> on Mutator<Whole, Call<Req, Res>> {
  Mutator<Whole, Launched<Req, Res>> get launched => composeWithPrism(
        Prism<Call<Req, Res>, Launched<Req, Res>>(
          Preview<Call<Req, Res>, Launched<Req, Res>>((whole) => whole.launchedOrNone),
          Getter<Launched<Req, Res>, Call<Req, Res>>((part) => part),
        ),
      );

  Mutator<Whole, Returned<Req, Res>> get returned => composeWithPrism(
        Prism<Call<Req, Res>, Returned<Req, Res>>(
          Preview<Call<Req, Res>, Returned<Req, Res>>((whole) => whole.returnedOrNone),
          Getter<Returned<Req, Res>, Call<Req, Res>>((part) => part),
        ),
      );
}

extension CallObminOpticIsoExtension<Whole, Req, Res> on Iso<Whole, Call<Req, Res>> {
  Prism<Whole, Launched<Req, Res>> get launched => composeWithPrism(
        Prism<Call<Req, Res>, Launched<Req, Res>>(
          Preview<Call<Req, Res>, Launched<Req, Res>>((whole) => whole.launchedOrNone),
          Getter<Launched<Req, Res>, Call<Req, Res>>((part) => part),
        ),
      );

  Prism<Whole, Returned<Req, Res>> get returned => composeWithPrism(
        Prism<Call<Req, Res>, Returned<Req, Res>>(
          Preview<Call<Req, Res>, Returned<Req, Res>>((whole) => whole.returnedOrNone),
          Getter<Returned<Req, Res>, Call<Req, Res>>((part) => part),
        ),
      );
}

extension CallObminOpticPrismExtension<Whole, Req, Res> on Prism<Whole, Call<Req, Res>> {
  Prism<Whole, Launched<Req, Res>> get launched => compose(
        Prism<Call<Req, Res>, Launched<Req, Res>>(
          Preview<Call<Req, Res>, Launched<Req, Res>>((whole) => whole.launchedOrNone),
          Getter<Launched<Req, Res>, Call<Req, Res>>((part) => part),
        ),
      );

  Prism<Whole, Returned<Req, Res>> get returned => compose(
        Prism<Call<Req, Res>, Returned<Req, Res>>(
          Preview<Call<Req, Res>, Returned<Req, Res>>((whole) => whole.returnedOrNone),
          Getter<Returned<Req, Res>, Call<Req, Res>>((part) => part),
        ),
      );
}

extension CallObminOpticReflectorExtension<Whole, Req, Res> on Reflector<Whole, Call<Req, Res>> {
  BiPreview<Whole, Launched<Req, Res>> get launched => composeWithPrism(
        Prism<Call<Req, Res>, Launched<Req, Res>>(
          Preview<Call<Req, Res>, Launched<Req, Res>>((whole) => whole.launchedOrNone),
          Getter<Launched<Req, Res>, Call<Req, Res>>((part) => part),
        ),
      );

  BiPreview<Whole, Returned<Req, Res>> get returned => composeWithPrism(
        Prism<Call<Req, Res>, Returned<Req, Res>>(
          Preview<Call<Req, Res>, Returned<Req, Res>>((whole) => whole.returnedOrNone),
          Getter<Returned<Req, Res>, Call<Req, Res>>((part) => part),
        ),
      );
}

extension CallObminOpticBiPreviewExtension<Whole, Req, Res> on BiPreview<Whole, Call<Req, Res>> {
  BiPreview<Whole, Launched<Req, Res>> get launched => composeWithPrism(
        Prism<Call<Req, Res>, Launched<Req, Res>>(
          Preview<Call<Req, Res>, Launched<Req, Res>>((whole) => whole.launchedOrNone),
          Getter<Launched<Req, Res>, Call<Req, Res>>((part) => part),
        ),
      );

  BiPreview<Whole, Returned<Req, Res>> get returned => composeWithPrism(
        Prism<Call<Req, Res>, Returned<Req, Res>>(
          Preview<Call<Req, Res>, Returned<Req, Res>>((whole) => whole.returnedOrNone),
          Getter<Returned<Req, Res>, Call<Req, Res>>((part) => part),
        ),
      );
}
