
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

final class CheckSystemSettingsUseCase {

  /// On Android: returns `true` if battery optimization is still enabled.
  /// On iOS: returns `true` if “Always” location permission is denied.
  Future<bool> call() async {
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

}