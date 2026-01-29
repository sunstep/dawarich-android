import 'package:auto_route/auto_route.dart';
import 'package:dawarich/core/routing/guards/auth_guard.dart';
import 'package:dawarich/core/shell/splash_view.dart';
import 'package:dawarich/features/auth/presentation/views/auth_qr_scan_view.dart';
import 'package:dawarich/features/auth/presentation/views/auth_view.dart';
import 'package:dawarich/features/batch/presentation/views/batch_explorer_view.dart';
import 'package:dawarich/features/points/presentation/views/points_view.dart';
import 'package:dawarich/features/settings/presentation/views/settings_view.dart';
import 'package:dawarich/features/stats/presentation/views/stats_view.dart';
import 'package:dawarich/features/timeline/presentation/views/timeline_view.dart';
import 'package:dawarich/features/tracking/presentation/views/tracker_view.dart';
import 'package:dawarich/features/version_check/presentation/views/version_check_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page|Screen|View,Route')
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

  /// Convert a path string to a PageRouteInfo.
  /// Returns TimelineRoute as default if path is not recognized.
  static PageRouteInfo routeFromPath(String path) {
    switch (path) {
      case '/tracker':
        return const TrackerRoute();
      case '/timeline':
        return const TimelineRoute();
      case '/stats':
        return const StatsRoute();
      case '/points':
        return const PointsRoute();
      case '/settings':
        return const SettingsRoute();
      case '/batchExplorer':
        return const BatchExplorerRoute();
      case '/auth':
        return const AuthRoute();
      default:
        return const TimelineRoute();
    }
  }

}
