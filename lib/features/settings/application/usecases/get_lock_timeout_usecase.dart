import 'package:dawarich/features/settings/application/repositories/app_settings_repository_interfaces.dart';

final class GetLockTimeoutUseCase {
  final IAppSettingsRepository _repository;

  GetLockTimeoutUseCase(this._repository);

  /// Returns the lock timeout in seconds. 0 = immediately.
  Future<int> call(int userId) {
    return _repository.getLockTimeoutSeconds(userId);
  }
}

