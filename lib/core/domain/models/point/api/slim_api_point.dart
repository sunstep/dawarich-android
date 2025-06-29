import 'package:dawarich/features/timeline/data_contracts/data_transfer_objects/slim_api_point_dto.dart';

class SlimApiPoint {
  String? latitude;
  String? longitude;
  int? timestamp;

  SlimApiPoint(SlimApiPointDTO dto) {
    latitude = dto.latitude;
    longitude = dto.longitude;
    timestamp = dto.timestamp;
  }
}
