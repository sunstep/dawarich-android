import 'package:dawarich/features/settings/application/repositories/app_settings_repository_interfaces.dart';

final class IsBiometricLockEnabledUseCase {
  final IAppSettingsRepository _repository;

  IsBiometricLockEnabledUseCase(this._repository);

  Future<bool> call(int userId) {
    return _repository.isBiometricLockEnabled(userId);
  }
}

