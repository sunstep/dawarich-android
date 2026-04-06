import 'package:dawarich/features/settings/application/repositories/app_settings_repository_interfaces.dart';

/// Tracks when the app was last paused and authenticated, per user.
/// Uses the Drift-backed app settings repository for persistence.
final class AppLockTimestampTracker {
  AppLockTimestampTracker._();

  static final AppLockTimestampTracker instance = AppLockTimestampTracker._();

  DateTime? _pausedAt;
  DateTime? _authenticatedAt;

  /// Grace period after authentication during which the lock won't trigger
  /// (prevents re-lock during route transition pause/resume cycles).
  static const _gracePeriod = Duration(seconds: 5);

  /// Load the last authenticated time for a specific user from the database.
  Future<void> initialize(IAppSettingsRepository repository, int userId) async {
    _authenticatedAt = await repository.getLastAuthenticatedAt(userId);
  }

  /// Called when the app transitions to paused state.
  void onPaused() {
    if (_isWithinGracePeriod()) return;
    _pausedAt = DateTime.now();
  }

  /// Called after a successful authentication. Persists the timestamp per user.
  Future<void> onAuthenticated(
      IAppSettingsRepository repository, int userId) async {
    _authenticatedAt = DateTime.now();
    _pausedAt = null;
    await repository.setLastAuthenticatedAt(userId, _authenticatedAt!);
  }

  /// Returns true if the lock should be shown based on the configured timeout.
  /// [timeoutSeconds] of 0 means always lock immediately.
  bool shouldLock({required int timeoutSeconds}) {
    if (_isWithinGracePeriod()) return false;

    // On cold start, _pausedAt is null. Use _authenticatedAt as reference
    // for how long the user has been "away".
    final reference = _pausedAt ?? _authenticatedAt;

    // Never authenticated and never paused → fresh install, always lock.
    if (reference == null) return true;

    if (timeoutSeconds == 0) return true;

    final elapsed = DateTime.now().difference(reference).inSeconds;
    return elapsed >= timeoutSeconds;
  }

  bool _isWithinGracePeriod() {
    return _authenticatedAt != null &&
        DateTime.now().difference(_authenticatedAt!) < _gracePeriod;
  }
}
