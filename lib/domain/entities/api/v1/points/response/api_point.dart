import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/api_point_dto.dart';
import 'package:dawarich/domain/entities/api/v1/points/response/api_point_geodata.dart';

class ApiPoint {
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
  Geodata? geodata;

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
    inrids = dto.inrids;
    inRegions = dto.inRegions;
    city = dto.city;
    country = dto.country;
    geodata = dto.geodata != null ? Geodata(dto.geodata!) : null;
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['battery_status'] = batteryStatus;
    data['ping'] = ping;
    data['battery'] = battery;
    data['tracker_id'] = trackerId;
    data['topic'] = topic;
    data['altitude'] = altitude;
    data['longitude'] = longitude;
    data['velocity'] = velocity;
    data['trigger'] = trigger;
    data['bssid'] = bssid;
    data['ssid'] = ssid;
    data['connection'] = connection;
    data['vertical_accuracy'] = verticalAccuracy;
    data['accuracy'] = accuracy;
    data['timestamp'] = timestamp;
    data['latitude'] = latitude;
    data['mode'] = mode;
    data['inrids'] = inrids;
    data['in_regions'] = inRegions;
    data['city'] = city;
    data['country'] = country;
    if (geodata != null) {
      data['geodata'] = geodata!.toJson();
    }
    return data;
  }
}