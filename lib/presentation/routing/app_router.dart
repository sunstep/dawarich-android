import 'package:flutter/material.dart';
import 'package:dawarich/presentation/pages/splash_page.dart';
import 'package:dawarich/presentation/pages/connect_page.dart';
import 'package:dawarich/presentation/pages/map_page.dart';
import 'package:dawarich/presentation/pages/stats_page.dart';
import 'package:dawarich/presentation/pages/points_page.dart';
import 'package:dawarich/presentation/pages/tracker_page.dart';
import 'package:dawarich/presentation/pages/imports_page.dart';
import 'package:dawarich/presentation/pages/exports_page.dart';
import 'package:dawarich/presentation/pages/settings_page.dart';

class AppRouter {

  static const String splash = '/splash';
  static const String connect = '/connect';
  static const String map = '/map';
  static const String stats = '/stats';
  static const String points = '/points';
  static const String tracker = '/tracker';
  static const String imports = '/imports';
  static const String exports = '/exports';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings route) {

    switch (route.name){
      case splash: {
        return MaterialPageRoute(builder: (_) => const SplashPage());
      }
      case connect: {
        return MaterialPageRoute(builder: (_) => const ConnectionPage());
      }
      case map: {
        return MaterialPageRoute(builder: (_) => const MapPage());
      }
      case stats: {
        return MaterialPageRoute(builder: (_) => const StatsPage());
      }
      case points: {
        return MaterialPageRoute(builder: (_) => const PointsPage());
      }
      case tracker: {
        return MaterialPageRoute(builder: (_) => const TrackerPage());
      }
      case imports: {
        return MaterialPageRoute(builder: (_) => const ImportsPage());
      }
      case exports: {
        return MaterialPageRoute(builder: (_) => const ExportsPage());
      }
      case settings: {
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      }
      default: {
        return MaterialPageRoute(builder: (_) => const SplashPage());
      }
    }
  }
}