import 'package:auto_route/auto_route.dart';
import 'package:dawarich/core/routing/guards/auth_guard.dart';
import 'package:dawarich/core/shell/splash.dart';
import 'package:dawarich/features/migration/presentation/pages/migration_page.dart';
import 'package:dawarich/features/batch/presentation/views/batch_explorer_view.dart';
import 'package:dawarich/features/timeline/presentation/pages/timeline_page.dart';
import 'package:dawarich/features/stats/presentation/pages/stats_page.dart';
import 'package:dawarich/features/points/presentation/pages/points_page.dart';
import 'package:dawarich/features/tracking/presentation/pages/tracker_page.dart';
import 'package:dawarich/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/views/auth_page.dart';
import '../../features/auth/presentation/views/auth_qr_scan_page.dart';
import '../../features/version_check/presentation/views/version_check_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
final class AppRouter extends RootStackRouter {

  final ProviderContainer container;
  late final AuthGuard _authGuard;

  AppRouter(this.container) {
    _authGuard = AuthGuard(container);
  }

  @override
  List<AutoRoute> get routes => [
    // Public routes (no auth required)
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: MigrationRoute.page, path: '/migration'),
    AutoRoute(page: AuthRoute.page, path: '/auth'),
    AutoRoute(page: AuthQrScanRoute.page, path: '/qrScan'),
    AutoRoute(page: VersionCheckRoute.page, path: '/versionCheck'),

    // Protected routes (auth required)
    AutoRoute(page: TimelineRoute.page, path: '/timeline', guards: [_authGuard]),
    AutoRoute(page: StatsRoute.page, path: '/stats', guards: [_authGuard]),
    AutoRoute(page: PointsRoute.page, path: '/points', guards: [_authGuard]),
    AutoRoute(page: TrackerRoute.page, path: '/tracker', guards: [_authGuard]),
    AutoRoute(page: BatchExplorerRoute.page, path: '/batchExplorer', guards: [_authGuard]),
    AutoRoute(page: SettingsRoute.page, path: '/settings', guards: [_authGuard]),
  ];

}
