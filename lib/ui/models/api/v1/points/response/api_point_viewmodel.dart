import 'package:dawarich/domain/entities/api/v1/points/response/api_point.dart';
import 'package:dawarich/ui/models/api/v1/points/response/api_point_geodata_viewmodel.dart';

class ApiPointViewModel {
  int? id;
  String? batteryStatus;
  dynamic ping;
  int? battery;
  String? trackerId;
  String? topic;
  int? altitude;
  String? longitude;
  String? velocity;
  String? trigger;
  String? bssid;
  String? ssid;
  String? connection;
  int? verticalAccuracy;
  int? accuracy;
  int? timestamp;
  String? latitude;
  dynamic mode;
  String? city;
  String? country;
  GeoDataViewModel? geodata;

  ApiPointViewModel(ApiPoint point) {
    id = point.id;
    batteryStatus = point.batteryStatus;
    ping = point.ping;
    battery = point.battery;
    trackerId = point.trackerId;
    topic = point.topic;
    altitude = point.altitude;
    longitude = point.longitude;
    velocity = point.velocity;
    trigger = point.trigger;
    bssid = point.bssid;
    ssid = point.ssid;
    connection = point.connection;
    verticalAccuracy = point.verticalAccuracy;
    accuracy = point.accuracy;
    timestamp = point.timestamp;
    latitude = point.latitude;
    mode = point.mode;
    city = point.city;
    country = point.country;
    geodata = point.geodata != null ? GeoDataViewModel(point.geodata!) : null;
  }
}
