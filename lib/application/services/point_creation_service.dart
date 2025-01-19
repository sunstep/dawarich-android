
import 'dart:io';

import 'package:dawarich/domain/entities/api/v1/overland/batches/request/geometry.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/properties.dart';

import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

class PointCreationService {

  late Position _position;

  Future<Point> constructPoint() async {

    await _getPosition();
    Geometry geometry = await _constructPointGeometry();
    Properties properties = await _constructPointProperties();

    return Point(type: "Feature", geometry: geometry, properties: properties);
  }

  Future<Geometry> _constructPointGeometry() async {


    return Geometry(type: "Point", coordinates: [_position.longitude, _position.latitude]);
  }

  Future<Properties> _constructPointProperties() async {

    String timestamp = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    Map<String, dynamic> batteryInfo = await _getBatteryInfo();

    return Properties(
        timestamp: timestamp,
        altitude: _position.altitude,
        speed: _position.speed,
        horizontalAccuracy: _position.accuracy,
        verticalAccuracy: _position.altitudeAccuracy,
        motion: [],
        pauses: false,
        activity: "",
        desiredAccuracy: 0.0,
        deferred: 0.0,
        significantChange: "",
        locationsInPayload: 0,
        deviceId: await _getDeviceId(),
        wifi: await _getWiFiStatus(),
        batteryState: batteryInfo['state'],
        batteryLevel: batteryInfo['level']
    );
  }

  Future<void> _getPosition() async {

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,

      ),
    );

    _position = position;
  }

  Future<String> _getDeviceId() async {

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

  Future<String> _getWiFiStatus() async {

    final List<ConnectivityResult> connectivityResults =
    await Connectivity().checkConnectivity();

    if (connectivityResults.contains(ConnectivityResult.wifi)) {
      try {
        final NetworkInfo wifiInfo = NetworkInfo();
        final String? ssid = await wifiInfo.getWifiName();
        return ssid ?? "Unknown";
      } catch (e) {
        return "Unknown";
      }
    } else {
      return "No Wi-Fi";
    }
  }

  Future<Map<String, dynamic>> _getBatteryInfo() async {

    final Battery battery = Battery();

    final int iLevel = await battery.batteryLevel;
    final double fLevel = iLevel.toDouble();

    final String batteryState = battery.batteryState.toString();

    return { 'level': fLevel, 'state': batteryState };
  }


}