import 'package:flutter/material.dart';
import 'package:dawarich/application/dependency_injection/service_locator.dart';
import 'package:dawarich/ui/theme/app_theme.dart';
import 'package:dawarich/ui/routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  injectDependencies();
  runApp(const AppBase());
}

class AppBase extends StatelessWidget {
  const AppBase({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dawarich',
      theme: Themes().lightTheme,
      darkTheme: Themes().darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/splash',
    );
  }
}
