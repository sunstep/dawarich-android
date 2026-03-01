import 'dart:async';

import 'package:dawarich/core/di/providers/session_providers.dart';
import 'package:dawarich/core/di/providers/usecase_providers.dart';
import 'package:dawarich/core/di/providers/version_check_providers.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/features/tracking/application/usecases/notifications/initialize_tracker_notification_usecase.dart';
import 'package:dawarich/main.dart';
import 'package:dawarich_android_user_module/dawarich_android_user_module.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class StartupService {
  static Future<void> initializeAppFromContainer(ProviderContainer container) async {
    if (kDebugMode) {
      debugPrint('[StartupService] Initializing app...');
    }

    final initNotif = container.read(initializeTrackerNotificationServiceUseCaseProvider);
    await initNotif();

    final DawarichAndroidUserModule<User> sessionService =
        await container.read(sessionBoxProvider.future);
    final User? refreshedSessionUser = await sessionService.refreshSession();

    if (refreshedSessionUser != null) {
      if (kDebugMode) {
        debugPrint('[StartupService] User session found!');
      }

      sessionService.setUserId(refreshedSessionUser.id);

      final refreshServerCompatibility =
          await container.read(refreshServerCompatibilityUseCaseProvider.future);
      await refreshServerCompatibility();


      final pendingRoute = InitializeTrackerNotificationServiceUseCase.pendingNotificationRoute;
      if (pendingRoute != null) {
        if (kDebugMode) {
          debugPrint('[StartupService] Navigating to pending notification route: $pendingRoute');
        }
        InitializeTrackerNotificationServiceUseCase.clearPendingRoute();

        final route = AppRouter.routeFromPath(pendingRoute);
        appRouter.replaceAll([route]);
        return;
      }

      if (kDebugMode) {
        debugPrint('[StartupService] Navigating to timeline screen...');
      }
      appRouter.replaceAll([const TimelineRoute()]);
      return;
    } else {
      if (kDebugMode) {
        debugPrint('[StartupService] No user session found, navigating to auth screen...');
      }
      sessionService.logout();
      appRouter.replaceAll([const AuthRoute()]);
    }
  }
}
