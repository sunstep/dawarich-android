import 'package:dawarich/features/version_check/domain/server_compatibility_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final serverCompatibilityProvider =
NotifierProvider<ServerCompatibilityNotifier, ServerCompatibilityState>(
  ServerCompatibilityNotifier.new,
);

final class ServerCompatibilityNotifier
    extends Notifier<ServerCompatibilityState> {
  @override
  ServerCompatibilityState build() {
    return ServerCompatibilityState.unknown(
      checkedAt: DateTime.fromMillisecondsSinceEpoch(0),
      message: null,
      reasonCode: 'NOT_CHECKED_YET',
    );
  }

  void setState(ServerCompatibilityState newState) {
    state = newState;
  }

  void setUnknown({
    required DateTime checkedAt,
    String? message,
    String? reasonCode,
  }) {
    state = ServerCompatibilityState.unknown(
      checkedAt: checkedAt,
      message: message,
      reasonCode: reasonCode,
    );
  }
}