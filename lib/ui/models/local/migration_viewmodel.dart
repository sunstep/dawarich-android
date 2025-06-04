import 'package:dawarich/application/services/migration_service.dart';
import 'package:flutter/foundation.dart';

final class MigrationViewModel extends ChangeNotifier {
  bool _isMigrating = false;
  String? _error;

  bool get isMigrating => _isMigrating;
  String? get error => _error;

  Future<void> runMigration() async {
    _setMigrating(true);
    try {
      await MigrationService.runIfNeeded();
      _setError(null);
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
