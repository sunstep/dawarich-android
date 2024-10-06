import 'package:flutter/material.dart';
import 'package:dawarich/presentation/routing/app_router.dart';
import 'package:dawarich/presentation/theme/app_theme.dart';
import 'package:dawarich/application/dependency_injection/service_locator.dart';

void main() {
  injectDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

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

