import 'package:auto_route/auto_route.dart';
import 'package:dawarich/core/shell/splash.dart';
import 'package:dawarich/features/auth/presentation/pages/auth_page.dart';
import 'package:dawarich/features/migration/presentation/pages/migration_page.dart';
import 'package:dawarich/features/batch/presentation/pages/batch_explorer_page.dart';
import 'package:dawarich/features/version_check/presentation/pages/version_check_page.dart';
import 'package:dawarich/features/timeline/presentation/pages/timeline_page.dart';
import 'package:dawarich/features/stats/presentation/pages/stats_page.dart';
import 'package:dawarich/features/points/presentation/pages/points_page.dart';
import 'package:dawarich/features/tracking/presentation/pages/tracker_page.dart';
import 'package:dawarich/features/settings/presentation/pages/settings_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
final class AppRouter extends RootStackRouter {

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: MigrationRoute.page, path: '/migration'),
    AutoRoute(page: AuthRoute.page, path: '/auth'),
    AutoRoute(page: VersionCheckRoute.page, path: '/versionCheck'),
    AutoRoute(page: TimelineRoute.page, path: '/timeline'),
    AutoRoute(page: StatsRoute.page, path: '/stats'),
    AutoRoute(page: PointsRoute.page, path: '/points'),
    AutoRoute(page: TrackerRoute.page, path: '/tracker'),
    AutoRoute(page: BatchExplorerRoute.page, path: '/batchExplorer'),
    AutoRoute(page: SettingsRoute.page, path: '/settings'),
  ];


}
