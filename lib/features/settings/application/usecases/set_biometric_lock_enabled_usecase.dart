import 'package:dawarich/features/settings/application/repositories/app_settings_repository_interfaces.dart';

final class SetBiometricLockEnabledUseCase {
  final IAppSettingsRepository _repository;

  SetBiometricLockEnabledUseCase(this._repository);

  Future<void> call(int userId, {required bool enabled}) {
    return _repository.setBiometricLockEnabled(userId, enabled);
  }
}

