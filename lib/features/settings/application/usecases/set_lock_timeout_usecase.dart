import 'package:dawarich/features/settings/application/repositories/app_settings_repository_interfaces.dart';

final class SetLockTimeoutUseCase {
  final IAppSettingsRepository _repository;

  SetLockTimeoutUseCase(this._repository);

  /// Sets the lock timeout in seconds. 0 = immediately.
  Future<void> call(int userId, {required int seconds}) {
    return _repository.setLockTimeoutSeconds(userId, seconds);
  }
}

