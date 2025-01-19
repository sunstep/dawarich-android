
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceDataSource {

  Future<String> getDeviceId() async {

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.model;
    } else {
      return "Unknown";
    }
  }

}