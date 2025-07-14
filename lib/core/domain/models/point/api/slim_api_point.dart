import 'package:dawarich/features/timeline/data_contracts/data_transfer_objects/slim_api_point_dto.dart';

final class SlimApiPoint {
  String? latitude;
  String? longitude;
  int? timestamp;

  SlimApiPoint({
    this.latitude,
    this.longitude,
    this.timestamp,
  });
}
