import 'api_point_raw_data.dart';
import 'api_point_geodata.dart';

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
  RawData? rawData;
  dynamic importId;
  String? city;
  String? country;
  String? createdAt;
  String? updatedAt;
  int? userId;
  Geodata? geodata;
  dynamic visitId;

  ApiPoint(Map<String, dynamic> point) {
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
    rawData = point['raw_data'] != null ? RawData(point['raw_data']) : null;
    importId = point['import_id'];
    city = point['city'];
    country = point['country'];
    createdAt = point['created_at'];
    updatedAt = point['updated_at'];
    userId = point['user_id'];
    geodata = point['geodata'] != null ? Geodata(point['geodata']) : null;
    visitId = point['visit_id'];
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
    if (rawData != null) {
      data['raw_data'] = rawData!.toJson();
    }
    data['import_id'] = importId;
    data['city'] = city;
    data['country'] = country;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['user_id'] = userId;
    if (geodata != null) {
      data['geodata'] = geodata!.toJson();
    }
    data['visit_id'] = visitId;
    return data;
  }
}