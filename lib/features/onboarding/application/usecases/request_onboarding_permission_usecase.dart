import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:dawarich/features/onboarding/domain/permission_item.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Requests a specific permission identified by [PermissionItem.id].
///
/// Returns `true` if the permission was granted, `false` otherwise.
/// For battery optimization on Android, this opens the system settings intent.
final class RequestOnboardingPermissionUseCase {
  Future<bool> call(String permissionId) async {
    if (permissionId == PermissionIds.notification) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }

    if (permissionId == PermissionIds.locationAlways) {
      // Request "when in use" first, then "always" — Android requires this.
      final whenInUse = await Permission.locationWhenInUse.request();
      if (!whenInUse.isGranted) return false;

      final always = await Permission.locationAlways.request();
      return always.isGranted;
    }

    if (permissionId == PermissionIds.batteryOptimization) {
      if (Platform.isAndroid) {
        final packageInfo = await PackageInfo.fromPlatform();
        await AndroidIntent(
          action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
          data: 'package:${packageInfo.packageName}',
        ).launch();
        // The user will return from settings — caller should re-check.
        return true;
      }
      return true;
    }

    return false;
  }
}


