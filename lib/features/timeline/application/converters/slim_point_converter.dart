
import 'package:dawarich/core/domain/models/point/api/slim_api_point.dart';
import 'package:dawarich/features/timeline/data/data_transfer_objects/slim_api_point_dto.dart';

extension SlimPointDtoToDomain on SlimApiPointDTO {
  /// Converts a [SlimPointDto] to a [SlimPoint].
  SlimApiPoint toDomain() {
    return SlimApiPoint(
      timestamp: timestamp,
      longitude: longitude,
      latitude: latitude,
    );
  }
}

extension SlimPointToDto on SlimApiPoint {
  /// Converts a [SlimPoint] to a [SlimPointDto].
  SlimApiPointDTO toDto() {
    return SlimApiPointDTO(
      timestamp: timestamp,
      longitude: longitude,
      latitude: latitude,
    );
  }
}