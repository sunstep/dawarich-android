import 'package:dawarich/features/migration/application/services/migration_service.dart';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/features/tracking/application/services/background_tracking_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:user_session_manager/user_session_manager.dart';

final class StartupService {
  static late final String initialRoute;

  static Future<void> initializeApp() async {

    final migrationService = GetIt.I<MigrationService>();
    bool needsMigration = false;
    try {
      needsMigration = await migrationService.needsMigration();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StartupService] Migration check failed, skipping: $e');
      }
    }

    if (needsMigration) {
      initialRoute = AppRouter.migration;
      return;
    }

    final UserSessionManager<int> sessionService = getIt<UserSessionManager<int>>();

    final bool isLoggedIn = await sessionService.isLoggedIn();


    if (isLoggedIn) {
      initialRoute = AppRouter.map;
    } else {
      initialRoute = AppRouter.connect;
    }
  }


}
