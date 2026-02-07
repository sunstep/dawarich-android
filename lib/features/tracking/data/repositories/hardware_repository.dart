import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dawarich/features/tracking/data/sources/device_data_client.dart';
import 'package:dawarich/features/tracking/data/sources/connectivity_data_client.dart';
import 'package:dawarich/features/tracking/application/repositories/hardware_repository_interfaces.dart';
import 'package:network_info_plus/network_info_plus.dart';

final class HardwareRepository implements IHardwareRepository {
  final DeviceDataClient _deviceDataClient;
  final ConnectivityDataClient _wiFiDataClient;

  HardwareRepository(
    this._deviceDataClient,
    this._wiFiDataClient,
  );

  @override
  Future<String> getDeviceModel() async {
    if (Platform.isAndroid) {
      return _deviceDataClient.getAndroidDeviceModel();
    } else if (Platform.isIOS) {
      return _deviceDataClient.getIOSDeviceModel();
    } else {
      return "Unknown";
    }
  }

  @override
  Future<String> getBatteryState() async {

    final Battery battery = Battery();
    BatteryState batteryState = await battery.batteryState;
    String stateString;

    if (batteryState == BatteryState.connectedNotCharging) {
      stateString = "connected_not_charging";
    } else {
      stateString = batteryState.toString().split('.').last;
    }

    return stateString;
  }

  @override
  Future<double> getBatteryLevel() async {
    return await Battery().batteryLevel / 100;
  }

  @override
  Future<String> getWiFiStatus() async {
    List<ConnectivityResult> connectionList =
        await _wiFiDataClient.getWiFiStatus();

    if (connectionList.contains(ConnectivityResult.wifi)) {
      try {
        final NetworkInfo wifiInfo = NetworkInfo();
        final String? rawSSID = await wifiInfo.getWifiName();

        // Clean the output by removing outer quotes.
        final String ssid = (rawSSID != null &&
                rawSSID.startsWith('"') &&
                rawSSID.endsWith('"'))
            ? rawSSID.substring(1, rawSSID.length - 1)
            : rawSSID ?? "Unknown";
        return ssid;
      } catch (e) {
        return "Unknown";
      }
    } else if (connectionList.contains(ConnectivityResult.mobile)) {
      return "Mobile Data";
    } else {
      return "No Connectivity";
    }
  }

}
