abstract interface class IUserSessionRepository {
  Future<int> getCurrentUserId();
  Future<void> setCurrentUserId(int userId);
  Future<void> clearSession();
}
