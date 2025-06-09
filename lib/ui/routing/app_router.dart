import 'package:dawarich/application/startup/dependency_injector.dart';
import 'package:dawarich/ui/models/local/migration_viewmodel.dart';
import 'package:dawarich/ui/views/migration/migration_page.dart';
import 'package:dawarich/ui/views/tracker/batch_explorer_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/ui/views/connect/connect_page.dart';
import 'package:dawarich/ui/views/map_page.dart';
import 'package:dawarich/ui/views/stats_page.dart';
import 'package:dawarich/ui/views/points_page.dart';
import 'package:dawarich/ui/views/tracker/tracker_page.dart';
import 'package:dawarich/ui/views/imports_page.dart';
import 'package:dawarich/ui/views/exports_page.dart';
import 'package:dawarich/ui/views/settings_page.dart';
import 'package:provider/provider.dart';

final class AppRouter {
  static const String migration = '/migration';
  static const String connect = '/connect';
  static const String map = '/map';
  static const String stats = '/stats';
  static const String points = '/points';
  static const String tracker = '/tracker';
  static const String batchExplorer = '/batchExplorer';
  static const String imports = '/imports';
  static const String exports = '/exports';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings route) {
    if (kDebugMode) {
      debugPrint('[AppRouter] Generating route: ${route.name}');
    }

    switch (route.name) {
      case migration:
        {
          return MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                    create: (_) => getIt<MigrationViewModel>(),
                    child: const MigrationPage(),
                  ));
        }
      case connect:
        {
          return MaterialPageRoute(builder: (_) => const ConnectPage());
        }
      case map:
        {
          return MaterialPageRoute(builder: (_) => const MapPage());
        }
      case stats:
        {
          return MaterialPageRoute(builder: (_) => const StatsPage());
        }
      case points:
        {
          return MaterialPageRoute(builder: (_) => const PointsPage());
        }
      case tracker:
        {
          return MaterialPageRoute(builder: (_) => const TrackerPage());
        }
      case batchExplorer:
        {
          return MaterialPageRoute(builder: (_) => const BatchExplorerPage());
        }
      case imports:
        {
          return MaterialPageRoute(builder: (_) => const ImportsPage());
        }
      case exports:
        {
          return MaterialPageRoute(builder: (_) => const ExportsPage());
        }
      case settings:
        {
          return MaterialPageRoute(builder: (_) => const SettingsPage());
        }
      default:
        {
          return MaterialPageRoute(builder: (_) => const ConnectPage());
        }
    }
  }
}
