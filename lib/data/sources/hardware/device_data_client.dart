import 'package:device_info_plus/device_info_plus.dart';

final class DeviceDataClient {
  Future<String> getAndroidDeviceModel() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model;
  }

  Future<String> getIOSDeviceModel() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.model;
  }
}
