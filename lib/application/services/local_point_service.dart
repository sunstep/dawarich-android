import 'package:dawarich/application/converters/batch/point_batch_converter.dart';
import 'package:dawarich/application/converters/batch/point_converter.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_dto.dart';
import 'package:dawarich/data_contracts/interfaces/local_point_repository_interfaces.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_batch.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point.dart';
import 'package:dawarich/ui/models/local/last_point.dart';
import 'package:option_result/option_result.dart';

class LocalPointService {

  final ILocalPointInterfaces _pointCreationInterfaces;

  LocalPointService(this._pointCreationInterfaces);

  // Future<Result<Point, String>> createPoint() async {
  //
  //   Option<PointDto> cachedPointResult = await _pointCreationInterfaces.createCachedPoint();
  //
  //   Result<PointDto, String> creationResult = await _pointCreationInterfaces.createPoint();
  //
  // }

  Future<LastPoint?> getLastPoint() async {

    Option<PointDto> pointResult = await _pointCreationInterfaces.getLastPoint();

    switch (pointResult) {

      case Some(value: PointDto pointDto): {
        Point point = pointDto.toEntity();
        return LastPoint(
            timestamp: point.properties.timestamp,
            latitude: point.geometry.coordinates[0],
            longitude: point.geometry.coordinates[1]
        );
      }

      case None(): {
        return null;
      }
    }
  }


  Future<int> getBatchPointsCount() async {

    return await _pointCreationInterfaces.getBatchPointCount();
  }

  Future<Result<void, String>> uploadBatch() async {

    List<Point> points = [];
    PointBatch batch = PointBatch(points: points);
    return await _pointCreationInterfaces.uploadBatch(batch.toDto());
  }
}