import 'dart:io';
import 'package:dawarich/data_contracts/interfaces/system_settings_repository_interfaces.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SystemSettingsRepository implements ISystemSettingsRepository {

  static const _channel = MethodChannel('app.dawarich/system_settings');

  @override
  Future<bool> needsSystemSettingsFix() async {

    if (Platform.isAndroid) {
      final bool enabled = await _channel.invokeMethod('isBatteryOptimizationEnabled');
      return enabled;
    } else if (Platform.isIOS) {
      final status = await Permission.locationAlways.status;
      return !status.isGranted;
    }
    return false;
  }

}