import 'package:dawarich/data_contracts/data_transfer_objects/local/additional_point_data_dto.dart';
import 'package:dawarich/domain/entities/local/additional_point_data.dart';

extension AdditionalPointToDto on AdditionalPointData {
  AdditionalPointDataDto toDto() => AdditionalPointDataDto(
      currentPointsInBatch, deviceId, wifi, batteryState, batteryLevel);
}
