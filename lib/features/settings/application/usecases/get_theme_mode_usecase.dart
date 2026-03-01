import 'package:dawarich/features/settings/application/repositories/app_settings_repository_interfaces.dart';

final class GetThemeModeUseCase {
  final IAppSettingsRepository _repository;

  GetThemeModeUseCase(this._repository);

  /// Returns 'system', 'light', or 'dark'.
  Future<String> call(int userId) {
    return _repository.getThemeMode(userId);
  }
}

