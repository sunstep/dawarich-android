import 'package:dawarich/data_contracts/data_transfer_objects/local/last_point_dto.dart';
import 'package:dawarich/domain/entities/local/last_point.dart';

extension LastPointDtoToDomain on LastPointDto {
  LastPoint toDomain() =>
      LastPoint(timestamp: timestamp, longitude: longitude, latitude: latitude);
}
