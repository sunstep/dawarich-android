import 'package:dawarich/features/migration/application/services/migration_service.dart';
import 'package:dawarich/core/session/user_session_service.dart';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:user_session_manager/user_session_manager.dart';

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
      final sessionService = getIt<UserSessionManager<int>>();
      final int? userId = await sessionService.getUser();

      if (userId != null && userId > 0) {
        // final apiConfig = getIt<ApiConfigService>();
        // await apiConfig.initialize();
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
