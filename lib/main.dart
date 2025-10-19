import 'dart:async';

import 'package:dawarich/core/database/drift/database/crypto/sqlcipher_bootstrap.dart';
import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/startup/startup_service.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/core/theme/dark_theme.dart';
import 'package:dawarich/core/theme/light_theme.dart';
import 'package:dawarich/features/tracking/application/services/background_tracking_service.dart';
import 'package:dawarich/features/tracking/application/services/tracking_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final AppRouter appRouter = AppRouter();

Future<void> main() async {

  BindingBase.debugZoneErrorsAreFatal = true;

  runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        await SqlcipherBootstrap.ensure();

        FlutterError.onError = (FlutterErrorDetails details) {
          debugPrint('[FlutterError] ${details.exceptionAsString()}');
          if (details.stack != null) debugPrint(details.stack!.toString());
          Zone.current.handleUncaughtError(
            details.exception,
            details.stack ?? StackTrace.current,
          );
        };

        // Catch errors outside Flutter widget tree (platform layer)
        PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
          debugPrint('[PlatformError] $error');
          debugPrint(stack.toString());
          return true;
        };

        try {
          await _dbHook();
        } catch (e, st) {
          debugPrint('[dbHook] $e\n$st');
        }

        runApp(const Dawarich());

        WidgetsBinding.instance.addPostFrameCallback((_) {

          if (kDebugMode) {
            debugPrint('[BOOT] first frame');
          }

          unawaited(_boot());
        });
      }, (Object error, StackTrace stack) {
        debugPrint('[ZonedError] $error');
        debugPrint(stack.toString());
      }
  );

}

Future<void> _dbHook() async {

  final int schemaVersion = SQLiteClient.kSchemaVersion;

  if (!kReleaseMode && const bool.fromEnvironment('DEV_FORCE_UPGRADE', defaultValue: false)) {
    final int target = schemaVersion - 1;

    await SQLiteClient.setUserVersion(target);
  }
}

Future<void> _boot() async {

  if (kDebugMode) {
    debugPrint('Booting up...');
  }
  try {
    await DependencyInjection.injectDependencies();
    await getIt.allReady();
    await getIt<TrackingNotificationService>().initialize();
    await StartupService.initializeApp();
    if (!await SQLiteClient.peekNeedsUpgrade()) {
      await BackgroundTrackingService.configureService();
    } else if (kDebugMode) {
      debugPrint('[Boot] Skipping tracker start due to pending DB upgrade');
    }
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint("Error during app bootstrap: $e\n$st");
    }
  }

  if (kDebugMode) {
    debugPrint('Boot completed.');
  }


}

class Dawarich extends StatelessWidget {

  const Dawarich({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: 'Dawarich',
        theme: LightTheme.primaryTheme,
        darkTheme: DarkTheme.primaryTheme,
        themeMode: ThemeMode.system,
        routerConfig: appRouter.config(
          navigatorObservers: () => [routeObserver],
        ),
    );
  }
}
