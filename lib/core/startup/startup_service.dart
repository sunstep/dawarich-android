import 'dart:async';

import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/di/providers/session_providers.dart';
import 'package:dawarich/core/di/providers/version_check_providers.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:dawarich/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:option_result/option_result.dart';
import 'package:session_box/session_box.dart';

final class StartupService {
  static Future<void> initializeAppFromContainer(ProviderContainer container) async {
    if (kDebugMode) {
      debugPrint('[StartupService] Initializing app...');
    }

    final willUpgrade = await SQLiteClient.peekNeedsUpgrade();
    if (willUpgrade) {
      if (kDebugMode) {
        debugPrint('[StartupService] Migration needed, navigating to migration screen...');
      }
      // Keep DB gate closed until MigrationViewModel marks DB ready.
      appRouter.replaceAll([const MigrationRoute()]);
      return;
    }

    // No migration needed -> allow DB to open.
    // NOTE: The DB gate lives in the widget-tree ProviderScope container.
    // Do not open it from this boot container.

    final SessionBox<User> sessionService =
        await container.read(sessionBoxProvider.future);
    final User? refreshedSessionUser = await sessionService.refreshSession();

    if (refreshedSessionUser != null) {
      if (kDebugMode) {
        debugPrint('[StartupService] User session found!');
      }

      sessionService.setUserId(refreshedSessionUser.id);

      final serverCompatabilityChecker =
          await container.read(serverVersionCompatibilityUseCase.future);
      final Result<(), Failure> isSupported = await serverCompatabilityChecker();

      if (!isSupported.isOk()) {
        if (kDebugMode) {
          debugPrint('[StartupService] Server version not supported, navigating to version check screen...');
        }
        appRouter.replaceAll([const VersionCheckRoute()]);
        return;
      }

      // Notification launch detection is not wired yet in Riverpod.
      // Default to timeline until this is implemented.
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
