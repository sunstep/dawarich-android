import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:user_session_manager/user_session_manager.dart';

final class MigrationViewModel extends ChangeNotifier {
  bool _isMigrating = false;
  String? _error;

  bool get isMigrating => _isMigrating;
  String? get error => _error;

  // final MigrationService _migrationService;
  // MigrationViewModel(this._migrationService);


  Future<void> runMigrationAndNavigate(BuildContext context) async {
    _setMigrating(true);
    try {
      _setError(null);

      await getIt<SQLiteClient>().customSelect('SELECT 1').get();

      // After migration, check login state
      final sessionService = getIt<UserSessionManager<int>>();
      final int? userId = await sessionService.getUser();

      if (context.mounted && userId != null && userId > 0) {
        Navigator.pushReplacementNamed(context, AppRouter.map);
      } else if (context.mounted) {
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
