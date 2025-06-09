import 'package:dawarich/application/services/api_config_service.dart';
import 'package:dawarich/application/services/migration_service.dart';
import 'package:dawarich/application/services/user_session_service.dart';
import 'package:dawarich/application/startup/dependency_injector.dart';
import 'package:dawarich/ui/routing/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

final class StartupService {
  static late final String initialRoute;

  static Future<void> initializeApp() async {
    // BackgroundTrackingService;

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

    final UserSessionService sessionService = getIt<UserSessionService>();
    final userId = await sessionService.getCurrentUserId();

    if (userId > 0) {
      final ApiConfigService apiConfig = getIt<ApiConfigService>();
      await apiConfig.initialize();
      initialRoute = AppRouter.map;
    } else {
      initialRoute = AppRouter.connect;
    }
  }
}
