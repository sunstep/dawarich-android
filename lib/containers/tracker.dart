import 'dart:io';

import 'package:dawarich/helpers/point_populator.dart';
import 'package:dawarich/models/point_geometry.dart';
import 'package:dawarich/models/point_properties.dart';
import 'package:dawarich/models/points.dart';
import 'package:flutter/cupertino.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:dawarich/helpers/endpoint.dart';
import 'point_api.dart';
import '../models/point_creator.dart';
import 'package:geolocator/geolocator.dart';


class TrackerContainer {

  String? _endpoint;
  String? _apiKey;
  DateTime selectedDate = DateTime.now();

  Map<String, String> lastPoint = <String, String>{};

  final PointPopulator _populator = PointPopulator();

  List<PointCreator> points = [];

  Future<void> fetchEndpointInfo(BuildContext context) async {

    EndpointResult endpointResult = Provider.of<EndpointResult>(context, listen: false);
    _endpoint = endpointResult.endPoint;
    _apiKey = endpointResult.apiKey;
  }

  void fetchLastPoint(){

    final PointApi api = PointApi(_endpoint!, _apiKey!, selectedDate, selectedDate);


  }

  Future<void> createPoint() async {

    final Position? position = await _populator.getCurrentLocation();
    final Battery battery = Battery();
    final BatteryState batteryState = await battery.batteryState;
    final int batteryLevel = await battery.batteryLevel;
    final NetworkInfo network = NetworkInfo();
    final String? networkName = await network.getWifiName();
    final DeviceInfoPlugin device = DeviceInfoPlugin();

    final AndroidDeviceInfo android;
    final IosDeviceInfo ios;
    final String deviceId;

    if (Platform.isAndroid){
      android = await device.androidInfo;
      deviceId = android.device;
    } else if (Platform.isIOS){
      ios = await device.iosInfo;
      deviceId = ios.name;
    } else {
      throw UnsupportedError("Platform is not supported");
    }

    if (position != null){
      final PointGeometry geometry = PointGeometry(coordinates: [position.latitude, position.longitude]);
      final PointProperties properties = PointProperties(
        timestamp: DateTime.now().toUtc().toIso8601String(),
        altitude: position.altitude,
        speed: position.speed*3.6,
        horizontalAccuracy: position.accuracy,
        verticalAccuracy: position.altitudeAccuracy,
        motion: [],
        pauses: false,
        activity: "unknown",
        desiredAccuracy: position.accuracy,
        deferred: 0.0,
        significantChange: "unknown",
        locationsInPayload: points.length+1,
        deviceId: deviceId,
        wifi: networkName?? "",
        batteryState: batteryState.toString(),
        batteryLevel: batteryLevel.toDouble()
      );

      final PointCreator point = PointCreator(geometry: geometry, properties: properties);
      points.add(point);
      final Points pointContainer = Points(pointsList: points);
      pointContainer.uploadPoints(_endpoint!, _apiKey!);
    }



  }
















}