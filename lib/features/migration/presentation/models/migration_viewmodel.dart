import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/features/tracking/application/services/background_tracking_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:session_box/session_box.dart';

final class MigrationViewModel extends ChangeNotifier {
  bool _isMigrating = false;
  String? _error;

  bool get isMigrating => _isMigrating;
  String? get error => _error;

  // final MigrationService _migrationService;
  // MigrationViewModel(this._migrationService);


  Future<void> startMigration(BuildContext context) async {

    _setMigrating(true);
    _setError(null);

    final db = getIt<SQLiteClient>();

    // Unblock onUpgrade first
    db.signalUiReadyForMigration();
    
    await db.ensureOpened();

    try {
      if (kDebugMode) {
        final version = await db.customSelect('PRAGMA user_version').getSingle();
        debugPrint('[Migration] Database version confirmed as: ${version.data['user_version']}');
      }

      await BackgroundTrackingService.configureService(force: true);

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
    _setMigrating(true);
    _setError(null);

    final db = getIt<SQLiteClient>();

    db.resetForRetry();
    db.signalUiReadyForMigration();
    await db.ensureOpened();

    try {

      if (kDebugMode) {
        final version = await db.customSelect('PRAGMA user_version').getSingle();
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
    final SessionBox<User> sessionService = getIt<SessionBox<User>>();
    final User? refreshedSessionUser = await sessionService.refreshSession();

    if (context.mounted && refreshedSessionUser != null) {
      sessionService.setUserId(refreshedSessionUser.id);
      context.router.root.replace(const TimelineRoute());
    } else {
      await sessionService.logout();
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
