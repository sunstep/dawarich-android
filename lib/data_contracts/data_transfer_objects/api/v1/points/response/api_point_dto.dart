import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/api_point_geodata_dto.dart';

final class ApiPointDTO {
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
  GeodataDTO? geodata;
  int? visitId;

  ApiPointDTO(Map<String, dynamic> point) {
    id = point['id'];
    batteryStatus = point['battery_status'];
    ping = point['ping'] as int;
    battery = point['battery'];
    trackerId = point['tracker_id'];
    topic = point['topic'];
    altitude = point['altitude'];
    longitude = point['longitude'];
    velocity = point['velocity'];
    trigger = point['trigger'];
    bssid = point['bssid'];
    ssid = point['ssid'];
    connection = point['connection'];
    verticalAccuracy = point['vertical_accuracy'];
    accuracy = point['accuracy'];
    timestamp = point['timestamp'];
    latitude = point['latitude'];
    mode = point['mode'];
    rawData = point['raw_data'];
    importId = point['import_id'];
    city = point['city'];
    country = point['country'];
    createdAt = point['created_at'];
    updatedAt = point['updated_at'];
    userId = point['user_id'];
    geodata = point['geodata'] != null ? GeodataDTO(point['geodata']) : null;
    visitId = point['visit_id'];
  }
}
