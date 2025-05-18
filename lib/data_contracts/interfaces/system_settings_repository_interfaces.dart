
abstract interface class ISystemSettingsRepository {

  /// On Android: returns `true` if battery optimization is still enabled.
  /// On iOS: returns `true` if “Always” location permission is denied.
  Future<bool> needsSystemSettingsFix();

}