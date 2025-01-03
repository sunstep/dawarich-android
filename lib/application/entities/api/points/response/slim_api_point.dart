import 'package:dawarich/domain/data_transfer_objects/api/points/response/slim_api_point_dto.dart';

class SlimApiPoint {

  String? latitude;
  String? longitude;
  int? timestamp;

  SlimApiPoint(SlimApiPointDTO dto){
    latitude = dto.latitude;
    longitude = dto.longitude;
    timestamp = dto.timestamp;
  }

}