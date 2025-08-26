import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dawarich/features/tracking/data/sources/device_data_client.dart';
import 'package:dawarich/features/tracking/data/sources/gps_data_client.dart';
import 'package:dawarich/features/tracking/data/sources/connectivity_data_client.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:option_result/option_result.dart';

final class HardwareRepository implements IHardwareRepository {
  final GpsDataClient _gpsDataClient;
  final DeviceDataClient _deviceDataClient;
  final ConnectivityDataClient _wiFiDataClient;

  HardwareRepository(
    this._gpsDataClient,
    this._deviceDataClient,
    this._wiFiDataClient,
  );

  @override
  Future<Result<Position, String>> getPosition(
      LocationAccuracy locationAccuracy) async {
    return await _gpsDataClient.getPosition(locationAccuracy);
  }

  @override
  Future<Option<Position>> getCachedPosition() async {
    return await _gpsDataClient.getCachedPosition();
  }

  @override
  Stream<Result<Position, String>> getPositionStream({
    required LocationAccuracy accuracy,
    required int minimumDistance,
  }) {
    return _gpsDataClient.getPositionStream(
      accuracy: accuracy,
      distanceFilter: minimumDistance,
    );
  }

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
