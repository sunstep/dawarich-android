abstract interface class IAppSettingsRepository {
  Future<bool> isBiometricLockEnabled(int userId);
  Future<void> setBiometricLockEnabled(int userId, bool enabled);
  Future<int> getLockTimeoutSeconds(int userId);
  Future<void> setLockTimeoutSeconds(int userId, int seconds);
  Future<DateTime?> getLastAuthenticatedAt(int userId);
  Future<void> setLastAuthenticatedAt(int userId, DateTime time);
}
