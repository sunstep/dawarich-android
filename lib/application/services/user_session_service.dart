import 'package:dawarich/data_contracts/interfaces/user_session_repository_interfaces.dart';

class UserSessionService {
  final IUserSessionRepository _sessionRepository;
  UserSessionService(this._sessionRepository);

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
