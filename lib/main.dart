import 'package:flutter/material.dart';
import 'package:dawarich/presentation/routing/app_router.dart';
import 'package:dawarich/presentation/theme/app_theme.dart';
import 'package:dawarich/helpers/endpoint.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => EndpointResult(),
    child: const MyApp(),
  ));
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

