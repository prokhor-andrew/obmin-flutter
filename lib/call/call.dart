sealed class Call<Req, Err, Res> {
  final String id;
  final Req req;

  Call({
    required this.id,
    required this.req,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Call<Req, Err, Res> && other.id == id && other.req == req;
  }

  @override
  int get hashCode => id.hashCode ^ req.hashCode;
}

final class Launched<Req, Err, Res> extends Call<Req, Err, Res> {
  Launched({
    required super.id,
    required super.req,
  });

  Failure<Req, Err, Res> fail(Err err) {
    return Failure(id: id, req: req, err: err);
  }

  Success<Req, Err, Res> succeed(Res res) {
    return Success(id: id, req: req, res: res);
  }

  Launched<Req, Err, Res> restart(Req req) {
    return Launched(id: id, req: req);
  }

  @override
  String toString() {
    return "Launched<$Req, $Err, $Res> { id=$id _ req=$req }";
  }
}

final class Failure<Req, Err, Res> extends Call<Req, Err, Res> {
  final Err err;

  Failure({
    required super.id,
    required super.req,
    required this.err,
  });

  @override
  String toString() {
    return "Failure<$Req, $Err, $Res> { id=$id _ req=$req _ err=$err }";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Failure<Req, Err, Res> && super == other && other.err == err;
  }

  @override
  int get hashCode => super.hashCode ^ err.hashCode;
}

final class Success<Req, Err, Res> extends Call<Req, Err, Res> {
  final Res res;

  Success({
    required super.id,
    required super.req,
    required this.res,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Success<Req, Err, Res> && super == other && other.res == res;
  }

  @override
  int get hashCode => super.hashCode ^ res.hashCode;
}
