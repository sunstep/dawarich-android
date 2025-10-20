
import 'package:dawarich/core/network/errors/remote_request_failure.dart';

sealed class NetworkEvent {
  const NetworkEvent();
}

final class RequestFailed extends NetworkEvent {
  const RequestFailed(this.failure, {required this.method, required this.url});
  final RemoteRequestFailure failure;
  final String method;
  final Uri url;
}