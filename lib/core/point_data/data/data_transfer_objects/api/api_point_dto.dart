import 'package:dawarich/core/point_data/data/data_transfer_objects/api/api_point_geodata_dto.dart';

final class ApiPointDTO {
  final int?    id;
  final String? batteryStatus;
  final int?    ping;
  final int?    battery;
  final String? trackerId;
  final String? topic;
  final int?    altitude;
  final String? longitude;
  final String? velocity;
  final String? trigger;
  final String? bssid;
  final String? ssid;
  final String? connection;
  final int?    verticalAccuracy;
  final int?    accuracy;
  final int?    timestamp;
  final String? latitude;
  final int?    mode;
  final String? rawData;
  final String? importId;
  final String? city;
  final String? country;
  final String? createdAt;
  final String? updatedAt;
  final int?    userId;
  final GeodataDTO? geodata;
  final int?    visitId;

  ApiPointDTO(Map<String, dynamic> json)
      : id               = (json['id']   as num?)?.toInt(),
        batteryStatus    = json['battery_status'] as String?,
        ping             = (json['ping'] as num?)?.toInt(),
        battery          = (json['battery'] as num?)?.toInt(),
        trackerId        = json['tracker_id'] as String?,
        topic            = json['topic'] as String?,
        altitude         = (json['altitude'] as num?)?.toInt(),
        longitude        = json['longitude'] as String?,
        velocity         = json['velocity'] as String?,
        trigger          = json['trigger'] as String?,
        bssid            = json['bssid'] as String?,
        ssid             = json['ssid'] as String?,
        connection       = json['connection'] as String?,
        verticalAccuracy = (json['vertical_accuracy'] as num?)?.toInt(),
        accuracy         = (json['accuracy'] as num?)?.toInt(),
        timestamp        = (json['timestamp'] as num?)?.toInt(),
        latitude         = json['latitude'] as String?,
        mode             = (json['mode'] as num?)?.toInt(),
        rawData          = json['raw_data'] as String?,
        importId         = json['import_id'] as String?,
        city             = json['city'] as String?,
        country          = json['country'] as String?,
        createdAt        = json['created_at'] as String?,
        updatedAt        = json['updated_at'] as String?,
        userId           = (json['user_id'] as num?)?.toInt(),
        geodata          = json['geodata'] != null
            ? GeodataDTO(json['geodata'] as Map<String, dynamic>)
            : null,
        visitId          = (json['visit_id'] as num?)?.toInt();

}
