import 'dart:async';

import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:user_session_manager/user_session_manager.dart';

final class StartupService {
  static late final String initialRoute;

  static Future<void> initializeApp() async {

    final SQLiteClient db = getIt<SQLiteClient>();

    final Future<bool> migrateFuture  = db.migrationStream.first;

    /*
      You might wonder what this is doing here: db migrations do not run until the db is first interacted with.
      Here we run a dummy query to force the migration to run on start up rather than deep in the app.
      This is kinda hacky, but Drift does not provide a way to check if migrations are about to be run or not.
      So the only way to know if there is a migration to run, is to make it run the migration.
      The reason we do this in the first place, is because we want to show a migration screen, if we don't, the app gets stuck on the splash screen while it runs the migrations which is not a good user experience.

      When the migration runs, it will signal there is a migration, after signalling, it will block the migration until the UI is ready.
      When the UI is ready, it signals that to the migration logic which then unblocks the migration and proceeds with it.

      Flow (in a nutshell):
      1. Trigger migration with a dummy query.
      2. Migration logic runs and signals that there is a migration. Migration blocks it self with a Completer.
      3. Using the migration signal, we decide to show the migration screen (or not).
      4. When the migration screen is ready, it signals the migration logic to proceed, so it unblocks.
    */
    unawaited(
      (() async {
        try {
          await db.customSelect('SELECT 1').get();
        } catch (_) {
          // This is just a dummy query so just let it cry about it.
        }
      })(),
    );

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
