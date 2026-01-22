import 'dart:async';

import 'package:dawarich/core/database/drift/database/crypto/sqlcipher_bootstrap.dart';
import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/di/providers/core_providers.dart';
import 'package:dawarich/core/startup/startup_service.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/core/theme/dark_theme.dart';
import 'package:dawarich/core/theme/light_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

      // Use ONE container for both ProviderScope (widget tree) and startup boot.
      final container = ProviderContainer();

      runApp(UncontrolledProviderScope(container: container, child: const Dawarich()));

      WidgetsBinding.instance.addPostFrameCallback((_) {

        if (kDebugMode) {
          debugPrint('[BOOT] first frame');
        }

        unawaited(_boot(container));
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

Future<void> _boot(ProviderContainer container) async {

  if (kDebugMode) {
    debugPrint('Booting up...');
  }
  try {

    await container.read(coreProvider.future);

    // Startup boot should use the same container used by ProviderScope.
    await StartupService.initializeAppFromContainer(container);

    // if (!await SQLiteClient.peekNeedsUpgrade()) {
    //   await BackgroundTrackingService.configureService();
    // } else if (kDebugMode) {
    //   debugPrint('[Boot] Skipping tracker start due to pending DB upgrade');
    // }
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint("Error during app bootstrap: $e\n$st");
    }
  }

  if (kDebugMode) {
    debugPrint('Boot completed.');
  }


}

class Dawarich extends ConsumerWidget {

  const Dawarich({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
        title: 'Dawarich',
        theme: LightTheme.primaryTheme,
        darkTheme: DarkTheme.primaryTheme,
        themeMode: ThemeMode.system,
        routerConfig: appRouter.config(),
    );
  }
}
