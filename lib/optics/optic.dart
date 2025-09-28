// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:obmin/func.dart';
import 'package:obmin/optics/poly_optic.dart';
import 'package:obmin/types/call.dart';
import 'package:obmin/types/either.dart';
import 'package:obmin/types/logger.dart';
import 'package:obmin/types/option.dart';
import 'package:obmin/types/result.dart';
import 'package:obmin/types/these.dart';
import 'package:obmin/types/validator.dart';
import 'package:obmin/types/writer.dart';

final class Optic<Whole, Part> {
  final PolyOptic<Whole, Whole, Part, Part> _optic;

  Func<Whole, Whole> run(Func<Part, Part> update) {
    return _optic.run(update);
  }

  Func<Whole, Whole> set(Part value) => run(constfunc(value));

  const Optic._(this._optic);

  static Optic<Whole, Part> fromPolyOptic<Whole, Part>(PolyOptic<Whole, Whole, Part, Part> polyOptic) {
    return Optic._(polyOptic);
  }

  static Optic<Whole, Part> fromRun<Whole, Part>(Func<Func<Part, Part>, Func<Whole, Whole>> run) {
    return fromPolyOptic(PolyOptic.fromRun(run));
  }

  static Optic<T, T> id<T>() {
    return Optic.fromPolyOptic(PolyOptic.id<T>());
  }

  static Optic<Whole, Part> adapter<Whole, Part>(
    Func<Whole, Part> focus,
    Func<Part, Whole> reconstruct,
  ) {
    return Optic.fromPolyOptic(PolyOptic.adapter<Whole, Whole, Part, Part>(focus, reconstruct));
  }

  static Optic<Whole, Part> lens<Whole, Part>(
    Func<Whole, Part> focus,
    Func<Whole, Func<Part, Whole>> reconstruct,
  ) {
    return Optic.fromPolyOptic(PolyOptic.lens<Whole, Whole, Part, Part>(focus, reconstruct));
  }

  static Optic<Whole, Part> prism<Whole, Part>(
    Func<Whole, Option<Part>> focus,
    Func<Part, Whole> reconstruct,
  ) {
    return Optic.fromPolyOptic(
      PolyOptic.prism<Whole, Whole, Part, Part>(
        (whole) => focus(whole).asEither().lmap(constfunc(whole)),
        reconstruct,
      ),
    );
  }

  static Optic<IList<Part>, Part> list<Part>() {
    return Optic.fromPolyOptic(PolyOptic.list<Part, Part>());
  }

  static Optic<Option<Part>, Part> option<Part>() {
    return Optic.fromPolyOptic(PolyOptic.option<Part, Part>());
  }

  static Optic<Writer<E, Part>, Part> writerValue<E, Part>() {
    return Optic.fromPolyOptic(PolyOptic.writerValue<E, Part, Part>());
  }

  static Optic<Writer<Part, E>, IList<Part>> writerList<E, Part>() {
    return Optic.fromPolyOptic(PolyOptic.writerList<E, Part, Part>());
  }

  static Optic<Either<E, Part>, Part> eitherRight<E, Part>() {
    return Optic.fromPolyOptic(PolyOptic.eitherRight<E, Part, Part>());
  }

  static Optic<Either<Part, E>, Part> eitherLeft<E, Part>() {
    return Optic.fromPolyOptic(PolyOptic.eitherLeft<E, Part, Part>());
  }

  static Optic<Call<E, Part>, Part> callReturned<E, Part>() {
    return Optic.fromPolyOptic(PolyOptic.callReturned<E, Part, Part>());
  }

  static Optic<Call<Part, E>, Part> callLaunched<E, Part>() {
    return Optic.fromPolyOptic(PolyOptic.callLaunched<E, Part, Part>());
  }

  static Optic<Result<E, Part>, Part> resultSuccess<E, Part>() {
    return Optic.fromPolyOptic(PolyOptic.resultSuccess<E, Part, Part>());
  }

  static Optic<Result<Part, E>, Part> resultFailure<E, Part>() {
    return Optic.fromPolyOptic(PolyOptic.resultFailure<E, Part, Part>());
  }

  static Optic<These<E, Part>, Part> theseRight<E, Part>() {
    return Optic.fromPolyOptic(PolyOptic.theseRight<E, Part, Part>());
  }

  static Optic<These<Part, E>, Part> theseLeft<E, Part>() {
    return Optic.fromPolyOptic(PolyOptic.theseLeft<E, Part, Part>());
  }

  static Optic<(E, Part), Part> tupleRight<E, Part>() {
    return Optic.fromPolyOptic(PolyOptic.tupleRight<E, Part, Part>());
  }

  static Optic<(Part, E), Part> tupleLeft<E, Part>() {
    return Optic.fromPolyOptic(PolyOptic.tupleLeft<E, Part, Part>());
  }

  static Optic<Validator<E, Part>, Part> validatorValue<E, Part>() {
    return Optic.fromPolyOptic(PolyOptic.validatorValue<E, Part, Part>());
  }

  static Optic<Validator<Part, E>, IList<Part>> validatorErrors<E, Part>() {
    return Optic.fromPolyOptic(PolyOptic.validatorErrors<E, Part, Part>());
  }

  static Optic<Logger<Part>, Part> logger<Part>() {
    return Optic.fromPolyOptic(PolyOptic.logger<Part, Part>());
  }

  static Optic<IMap<Key, Part>, Part> dict<Key, Part>() {
    return Optic.fromPolyOptic(PolyOptic.dict<Key, Part, Part>());
  }

  Optic<Whole, Sub> then<Sub, TSub>(Optic<Part, Sub> other) {
    return Optic.fromPolyOptic(_optic.then(other._optic));
  }

  Optic<Whole2, Part> after<Whole2>(Optic<Whole2, Whole> other) {
    return other.then(this);
  }
}
