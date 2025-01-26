import 'package:dawarich/application/converters/batch/point_batch_converter.dart';
import 'package:dawarich/data_contracts/interfaces/local_point_repository_interfaces.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_batch.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point.dart';
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


  Future<int> getBatchPointsCount() async {

    return await _pointCreationInterfaces.getBatchPointCount();
  }

  Future<Result<void, String>> uploadBatch() async {

    List<Point> points = [];
    PointBatch batch = PointBatch(points: points);
    return await _pointCreationInterfaces.uploadBatch(batch.toDto());
  }
}