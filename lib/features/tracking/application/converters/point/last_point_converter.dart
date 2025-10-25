import 'package:dawarich/features/tracking/data/data_transfer_objects/point/last_point_dto.dart';
import 'package:dawarich/features/tracking/domain/models/last_point.dart';

extension LastPointDtoToDomain on LastPointDto {
  LastPoint toDomain() =>
      LastPoint(timestamp: timestamp, longitude: longitude, latitude: latitude);
}
