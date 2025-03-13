
abstract interface class IUserSessionRepository {

  bool get isLoggedIn;
  Future<int> getCurrentUserId();
  Future<void> storeCurrentUserId(int userId);
  Future<void> clearSession();
}