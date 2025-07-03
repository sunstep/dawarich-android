import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/features/migration/presentation/models/migration_viewmodel.dart';
import 'package:dawarich/features/migration/presentation/pages/migration_page.dart';
import 'package:dawarich/features/batch/presentation/pages/batch_explorer_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/features/auth/presentation/pages/connect_page.dart';
import 'package:dawarich/features/timeline/presentation/pages/timeline_page.dart';
import 'package:dawarich/features/stats/presentation/pages/stats_page.dart';
import 'package:dawarich/features/points/presentation/pages/points_page.dart';
import 'package:dawarich/features/tracking/presentation/pages/tracker_page.dart';
import 'package:dawarich/features/settings/presentation/pages/settings_page.dart';
import 'package:provider/provider.dart';

final class AppRouter {

  static const String migration =     '/migration';
  static const String connect =       '/connect';
  static const String map =           '/map';
  static const String stats =         '/stats';
  static const String points =        '/points';
  static const String tracker =       '/tracker';
  static const String batchExplorer = '/batchExplorer';
  static const String settings =      '/settings';

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
          return MaterialPageRoute(builder: (_) => const TimelinePage());
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
