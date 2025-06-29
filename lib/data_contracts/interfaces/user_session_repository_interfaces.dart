abstract interface class ILegacyUserSessionRepository {
  Future<int> getCurrentUserId();
  Future<void> setCurrentUserId(int userId);
  Future<void> clearSession();
}
