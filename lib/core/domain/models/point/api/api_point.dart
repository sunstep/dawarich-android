import 'package:dawarich/core/point_data/data_transfer_objects/api/api_point_dto.dart';
import 'package:dawarich/core/domain/models/point/api/api_point_geodata.dart';

final class ApiPoint {
  int? id;
  String? batteryStatus;
  int? ping;
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
  int? mode;
  String? rawData;
  String? importId;
  String? city;
  String? country;
  String? createdAt;
  String? updatedAt;
  int? userId;
  Geodata? geodata;
  int? visitId;

  ApiPoint(ApiPointDTO dto) {
    id = dto.id;
    batteryStatus = dto.batteryStatus;
    ping = dto.ping;
    battery = dto.battery;
    trackerId = dto.trackerId;
    topic = dto.topic;
    altitude = dto.altitude;
    longitude = dto.longitude;
    velocity = dto.velocity;
    trigger = dto.trigger;
    bssid = dto.bssid;
    ssid = dto.ssid;
    connection = dto.connection;
    verticalAccuracy = dto.verticalAccuracy;
    accuracy = dto.accuracy;
    timestamp = dto.timestamp;
    latitude = dto.latitude;
    mode = dto.mode;
    rawData = dto.rawData;
    importId = dto.importId;
    city = dto.city;
    country = dto.country;
    createdAt = dto.createdAt;
    updatedAt = dto.updatedAt;
    userId = dto.userId;
    geodata = dto.geodata != null ? Geodata(dto.geodata!) : null;
    visitId = dto.visitId;
  }
}
