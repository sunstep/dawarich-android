import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

final class SystemSettingsService {
  /// On Android: returns `true` if battery optimization is still enabled.
  /// On iOS: returns `true` if “Always” location permission is denied.
  Future<bool> needsSystemSettingsFix() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String packageName = packageInfo.packageName;

    final channel = MethodChannel('$packageName/system_settings');

    if (Platform.isAndroid) {
      final bool enabled =
          await channel.invokeMethod('isBatteryOptimizationEnabled');
      return enabled;
    } else if (Platform.isIOS) {
      final status = await Permission.locationAlways.status;
      return !status.isGranted;
    }
    return false;
  }

  /// On Android: launch the “ignore battery optimizations” intent.
  /// On iOS: open the app’s system settings page.
  Future<void> openSystemSettings() async {
    if (Platform.isAndroid) {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String packageName = packageInfo.packageName;

      await AndroidIntent(
        action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
        data: 'package:$packageName',
      ).launch();
    } else if (Platform.isIOS) {
      await openAppSettings();
    }
  }
}
