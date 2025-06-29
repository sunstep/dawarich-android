import 'package:dawarich/core/session/domain/legacy_user_session_repository_interfaces.dart';

class LegacyUserSessionService {
  final ILegacyUserSessionRepository _sessionRepository;
  LegacyUserSessionService(this._sessionRepository);

  Future<bool> get isLoggedIn async => await getCurrentUserId() > 0;

  Future<int> getCurrentUserId() async {
    return await _sessionRepository.getCurrentUserId();
  }

  Future<void> storeCurrentUserId(int userId) async {
    await _sessionRepository.setCurrentUserId(userId);
  }

  Future<void> clearCurrentUserId() async {
    await _sessionRepository.clearSession();
  }
}
