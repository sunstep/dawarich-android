import 'dart:async';

import 'package:dawarich/core/di/providers/settings_providers.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/core/theme/dark_theme.dart';
import 'package:dawarich/core/theme/light_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
late final AppRouter appRouter;
final container = ProviderContainer();

Future<void> main() async {
  debugPrint('[main] Dart entrypoint reached');

  BindingBase.debugZoneErrorsAreFatal = true;

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      debugPrint('[main] WidgetsBinding initialized');

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

      appRouter = AppRouter(container);

      debugPrint('[main] Calling runApp');
      runApp(UncontrolledProviderScope(container: container, child: const Dawarich()));
      debugPrint('[main] runApp returned — first frame scheduled');

      // Log when the first frame actually renders (post-frame callback).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('[main] First frame rendered');
      });
    }, (Object error, StackTrace stack) {
      debugPrint('[ZonedError] $error');
      debugPrint(stack.toString());
    }
  );

}



class Dawarich extends ConsumerWidget {

  const Dawarich({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
        title: 'Dawarich',
        theme: LightTheme.primaryTheme,
        darkTheme: DarkTheme.primaryTheme,
        themeMode: themeMode,
        routerConfig: appRouter.config(),
    );
  }
}
