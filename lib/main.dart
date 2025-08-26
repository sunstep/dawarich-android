import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/startup/startup_service.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/core/theme/dark_theme.dart';
import 'package:dawarich/core/theme/light_theme.dart';
import 'package:dawarich/features/tracking/application/services/background_tracking_service.dart';
import 'package:flutter/material.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final AppRouter appRouter = AppRouter();

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await DependencyInjection.injectDependencies();
  await getIt.allReady();

  await StartupService.initializeApp();
  await BackgroundTrackingService.configureService();

  runApp(const Dawarich());
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
