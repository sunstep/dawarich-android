import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/request/dawarich_point_dto.dart';

class DawarichPointBatchDto {

  final List<DawarichPointDto> points;

  DawarichPointBatchDto({required this.points});

}