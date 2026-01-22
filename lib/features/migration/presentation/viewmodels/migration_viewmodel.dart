import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/di/providers/core_providers.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/features/tracking/application/services/background_tracking_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:session_box/session_box.dart';

final class MigrationViewModel extends ChangeNotifier {

  bool _isMigrating = false;
  String? _error;

  bool get isMigrating => _isMigrating;
  String? get error => _error;

  // final MigrationService _migrationService;
  final SQLiteClient _db;
  final SessionBox<User> _sessionBox;
  MigrationViewModel(this._db, this._sessionBox);


  Future<void> startMigration(BuildContext context) async {
    final container = ProviderScope.containerOf(context);
    _setMigrating(true);
    _setError(null);

    try {
      await _db.ensureOpened();

      // Allow main isolate to open DB after migration.
      container.read(dbGateProvider).open();

      await BackgroundTrackingService.markDbReady();
      await BackgroundTrackingService.configureService(force: true);

      if (kDebugMode) {
        final version = await _db.customSelect('PRAGMA user_version').getSingle();
        debugPrint('[Migration] Database version confirmed as: ${version.data['user_version']}');
      }

      if (context.mounted) {
        await _navigate(context);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setMigrating(false);
    }
  }

  Future<void> retryMigration(BuildContext context) async {
    final container = ProviderScope.containerOf(context);
    _setMigrating(true);
    _setError(null);

    _db.resetForRetry();
    await _db.ensureOpened();

    // Allow main isolate to open DB after migration.
    container.read(dbGateProvider).open();

    try {

      if (kDebugMode) {
        final version = await _db.customSelect('PRAGMA user_version').getSingle();
        debugPrint('[Migration] Database version confirmed as: ${version.data['user_version']}');
      }


      if (context.mounted) {
        await _navigate(context);
      }

    } catch (e) {
      _setError(e.toString());
    } finally {
      _setMigrating(false);
    }
  }
  Future<void> _navigate(BuildContext context) async {

    final User? refreshedSessionUser = await _sessionBox.refreshSession();

    if (context.mounted && refreshedSessionUser != null) {
      _sessionBox.setUserId(refreshedSessionUser.id);
      context.router.root.replace(const TimelineRoute());
    } else {
      await _sessionBox.logout();
      if (context.mounted) {
        context.router.root.replace(const AuthRoute());
      }
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
