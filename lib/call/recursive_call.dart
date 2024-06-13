import 'package:obmin/call/call.dart';
import 'package:obmin/call/result.dart';

final class RecursiveCall<Req, Res, Err> {
  final Call<Result<Res, Err>, Call<Req, RecursiveCall<Req, Res, Err>>> call;

  RecursiveCall(this.call);
}
