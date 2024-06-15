import 'package:obmin/call/call.dart';

final class RecursiveCall<Req, Res> {
  final Call<Res, Call<Req, RecursiveCall<Req, Res>>> call;

  RecursiveCall(this.call);
}

Call<Req, Res> _get<Req, Res>(RecursiveCall<Req, Res> rec) {
  switch (rec.call) {
    case Launched(req: final req):
      return Returned(req);
    case Returned(res: final res):
      switch (res) {
        case Launched(req: final req):
          return Launched(req);
        case Returned(res: final res):
          return _get(res);
      }
  }
}

RecursiveCall<Req, Res> _set<Req, Res>(RecursiveCall<Req, Res> whole, Call<Req, Res> call) {
  switch (whole.call) {
    case Launched():
      switch (call) {
        case Launched(req: final req):
          return RecursiveCall(Returned(Launched(req)));
        case Returned(res: final res):
          return RecursiveCall(Launched(res));
      }
    case Returned(res: final res):
      switch (res) {
        case Launched():
          switch (call) {
            case Launched(req: final req):
              return RecursiveCall(Returned(Launched(req)));
            case Returned(res: final res):
              return RecursiveCall(Returned(Returned(RecursiveCall(Launched(res)))));
          }
        case Returned(res: final res):
          return RecursiveCall(Returned(Returned(_set(res, call))));
      }
  }
}
