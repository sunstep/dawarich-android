import 'package:dawarich/features/settings/application/repositories/app_settings_repository_interfaces.dart';

final class SetThemeModeUseCase {
  final IAppSettingsRepository _repository;

  SetThemeModeUseCase(this._repository);

  /// Sets the theme mode. Must be 'system', 'light', or 'dark'.
  Future<void> call(int userId, {required String mode}) {
    return _repository.setThemeMode(userId, mode);
  }
}

