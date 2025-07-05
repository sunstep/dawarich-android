import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:user_session_manager/user_session_manager.dart';

final class StartupService {
  static late final String initialRoute;

  static Future<void> initializeApp() async {

    final SQLiteClient db = getIt<SQLiteClient>();

    final Future<bool> migrateFuture  = db.migrationStream.first;

    await db.customSelect('SELECT 1').get();

    final didMigrate = await migrateFuture;

    if (didMigrate) {
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
