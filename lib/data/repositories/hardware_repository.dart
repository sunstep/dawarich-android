import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dawarich/data/sources/hardware/battery_data_client.dart';
import 'package:dawarich/data/sources/hardware/device_data_client.dart';
import 'package:dawarich/data/sources/hardware/gps_data_client.dart';
import 'package:dawarich/data/sources/hardware/connectivity_data_client.dart';
import 'package:dawarich/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:option_result/option_result.dart';

class HardwareRepository implements IHardwareRepository {

  final GpsDataClient _gpsDataClient;
  final DeviceDataClient _deviceDataClient;
  final BatteryDataClient _batteryDataClient;
  final ConnectivityDataClient _wiFiDataClient;

  HardwareRepository(
    this._gpsDataClient,
    this._deviceDataClient,
    this._batteryDataClient,
    this._wiFiDataClient,
  );

  @override
  Future<Result<Position, String>> getPosition({required LocationAccuracy locationAccuracy, required int minimumDistance}) async {

    return await _gpsDataClient.getPosition(locationAccuracy: locationAccuracy, minimumDistance: minimumDistance);


  }

  @override
  Future<Option<Position>> getCachedPosition() async {
    return await _gpsDataClient.getCachedPosition();
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

    String batteryState = await _batteryDataClient.getBatteryState();

    if (batteryState == "connectedNotCharging") {
      batteryState = "full";
    } else if (batteryState == "discharging") {
      batteryState = "unplugged";
    }

    return batteryState;
  }

  @override
  Future<double> getBatteryLevel() async {
    return await _batteryDataClient.getBatteryLevel() / 100;
  }

  @override
  Future<String> getWiFiStatus() async {

    List<ConnectivityResult> connectionList = await _wiFiDataClient.getWiFiStatus();

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