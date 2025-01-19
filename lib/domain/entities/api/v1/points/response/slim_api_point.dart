import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/slim_api_point_dto.dart';

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