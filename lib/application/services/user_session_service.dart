
import 'package:dawarich/data_contracts/interfaces/user_session_repository_interfaces.dart';

class UserSessionService {

  final IUserSessionRepository _sessionRepository;
  UserSessionService(this._sessionRepository);

  bool get isLoggedIn => _sessionRepository.isLoggedIn;

  Future<int> getCurrentUserId() async {

    return await _sessionRepository.getCurrentUserId();
  }

  Future<void> storeCurrentUserId(int userId) async {

    await _sessionRepository.storeCurrentUserId(userId);
  }

  Future<void> clearCurrentUserId() async {
    await _sessionRepository.clearSession();
  }
}