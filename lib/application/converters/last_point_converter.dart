
import 'package:dawarich/data_contracts/data_transfer_objects/local/last_point_dto.dart';
import 'package:dawarich/domain/entities/local/last_point.dart';

extension LastPointToDto on LastPoint {

  LastPointDto toDto() => LastPointDto (
      timestamp: timestamp,
      longitude: longitude,
      latitude: latitude,
    );

}

extension LastPointViewModelToEntity on LastPointDto {

  LastPoint toEntity() => LastPoint(
      timestamp: timestamp,
      longitude: longitude,
      latitude: latitude
  );
}