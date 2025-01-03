import 'package:dawarich/domain/data_transfer_objects/api/points/response/api_point_geodata_dto.dart';

class ApiPointDTO {
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
  dynamic inrids;
  dynamic inRegions;
  String? city;
  String? country;
  GeodataDTO? geodata;

  ApiPointDTO(Map<String, dynamic> point) {
    id = point['id'];
    batteryStatus = point['battery_status'];
    ping = point['ping'];
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
    inrids = point['inrids'];
    inRegions = point['in_regions'];
    city = point['city'];
    country = point['country'];
    geodata = point['geodata'] != null ? GeodataDTO(point['geodata']) : null;
  }
}