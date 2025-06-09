import 'package:dawarich/application/services/api_config_service.dart';
import 'package:dawarich/application/services/migration_service.dart';
import 'package:dawarich/application/services/user_session_service.dart';
import 'package:dawarich/application/startup/dependency_injector.dart';
import 'package:dawarich/ui/routing/app_router.dart';
import 'package:flutter/cupertino.dart';

final class MigrationViewModel extends ChangeNotifier {
  bool _isMigrating = false;
  String? _error;

  bool get isMigrating => _isMigrating;
  String? get error => _error;

  final MigrationService _migrationService;
  MigrationViewModel(this._migrationService);

  Future<void> runMigration() async {
    _setMigrating(true);
    try {
      _setError(null);
      await _migrationService.runIfNeeded();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setMigrating(false);
    }
  }

  Future<void> runMigrationAndNavigate(BuildContext context) async {
    _setMigrating(true);
    try {
      await _migrationService.runIfNeeded();
      _setError(null);

      // After migration, check login state
      final sessionService = getIt<UserSessionService>();
      final userId = await sessionService.getCurrentUserId();

      if (userId > 0) {
        final apiConfig = getIt<ApiConfigService>();
        await apiConfig.initialize();
        Navigator.pushReplacementNamed(context, AppRouter.map);
      } else {
        Navigator.pushReplacementNamed(context, AppRouter.connect);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setMigrating(false);
    }
  }

  void _setMigrating(bool v) {
    _isMigrating = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }
}
