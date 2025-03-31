import 'package:dawarich/data/sources/local/shared_preferences/user_session.dart';
import 'package:dawarich/data_contracts/interfaces/user_session_repository_interfaces.dart';

final class UserSessionRepository implements IUserSessionRepository {

  final UserSessionClient _userSession;
  UserSessionRepository(this._userSession);

  @override
  bool get isLoggedIn => _userSession.isLoggedIn;

  @override
  Future<int> getCurrentUserId() async {

    if (!_userSession.sessionLoaded) {
      await _userSession.loadSession();
    }
    return _userSession.userId;
  }

  @override
  Future<void> storeCurrentUserId(int userId) async {
    await _userSession.saveSession(userId);
  }

  @override
  Future<void> clearSession() async {
    await _userSession.clearSession();
  }



}