import 'dart:async';

import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/features/tracking/application/usecases/notifications/was_launched_from_notification_usecase.dart';
import 'package:dawarich/features/version_check/application/usecases/server_version_compatability_usecase.dart';
import 'package:dawarich/main.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';
import 'package:session_box/session_box.dart';

final class StartupService {
  static Future<void> initializeApp() async {

    if (kDebugMode) {
      debugPrint('[StartupService] Initializing app...');
    }

    final willUpgrade = await SQLiteClient.peekNeedsUpgrade();

    if (willUpgrade) {

      if (kDebugMode) {
        debugPrint('[StartupService] Migration needed, navigating to migration screen...');
      }

      appRouter.replaceAll([const MigrationRoute()]);
      return;
    }

    // Get the session box and verify if the logged in user is still in the database
    final SessionBox<User> sessionService = getIt<SessionBox<User>>();
    final User? refreshedSessionUser = await sessionService.refreshSession();

    if (refreshedSessionUser != null) {

      if (kDebugMode) {
        debugPrint('[StartupService] User session found!');
      }

      sessionService.setUserId(refreshedSessionUser.id);

      final ServerVersionCompatabilityUseCase serverCompatabilityChecker =
        getIt<ServerVersionCompatabilityUseCase>();
      final Result<(), Failure> isSupported = await serverCompatabilityChecker();

      if (!isSupported.isOk()) {

        if (kDebugMode) {
          debugPrint('[StartupService] Server version not supported, navigating to version check screen...');
        }

        appRouter.replaceAll([const VersionCheckRoute()]);
        return;
      }

      final WasLaunchedFromNotificationUseCase notificationService = getIt<WasLaunchedFromNotificationUseCase>();

      final bool launchedByNotification = await notificationService();

      if (launchedByNotification) {

        if (kDebugMode) {
          debugPrint('[StartupService] App launched from tracking notification, navigating to tracker screen...');
        }
        appRouter.replaceAll([const TrackerRoute()]);
      } else {

        if (kDebugMode) {
          debugPrint('[StartupService] Navigating to timeline screen...');
        }
        appRouter.replaceAll([const TimelineRoute()]);
      }

    } else {

      if (kDebugMode) {
        debugPrint('[StartupService] No user session found, navigating to auth screen...');
      }
      sessionService.logout();
      appRouter.replaceAll([const AuthRoute()]);
    }
  }


}
