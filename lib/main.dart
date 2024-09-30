import 'package:dawarich/helpers/endpoint.dart';
import 'package:dawarich/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';


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
      home: const SplashPage(),
    );
  }


}

