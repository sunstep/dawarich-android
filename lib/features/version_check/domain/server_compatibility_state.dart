
import 'package:dawarich/features/version_check/domain/server_compatibility_status.dart';

final class ServerCompatibilityState {
  final ServerCompatibilityStatus status;

  final String? appVersion;
  final String? serverVersion;

  /// Optional: recommended server version range from the matched rule.
  final String? recommendServer;

  /// Optional: message from rules (or generated fallback).
  final String? message;

  /// Useful for debugging/UI: why did we end up here?
  final String? reasonCode;

  final DateTime checkedAt;

  const ServerCompatibilityState({
    required this.status,
    required this.checkedAt,
    this.appVersion,
    this.serverVersion,
    this.recommendServer,
    this.message,
    this.reasonCode,
  });

  const ServerCompatibilityState.unknown({
    required DateTime checkedAt,
    String? message,
    String? reasonCode,
  }) : this(
    status: ServerCompatibilityStatus.unknown,
    checkedAt: checkedAt,
    message: message,
    reasonCode: reasonCode,
  );

  bool get shouldWarn {
    if (status == ServerCompatibilityStatus.warning) {
      return true;
    }
    if (status == ServerCompatibilityStatus.incompatible) {
      return true;
    }
    return false;
  }
}