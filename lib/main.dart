import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/startup/startup_service.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/core/theme/dark_theme.dart';
import 'package:dawarich/core/theme/light_theme.dart';
import 'package:flutter/material.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await DependencyInjection.injectDependencies();
  await getIt.allReady();
  await StartupService.initializeApp();

  runApp(const AppBase());
}

class AppBase extends StatelessWidget {
  const AppBase({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Dawarich',
        theme: LightTheme.primaryTheme,
        darkTheme: DarkTheme.primaryTheme,
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: StartupService.initialRoute,
        navigatorObservers: [routeObserver]);
  }
}
