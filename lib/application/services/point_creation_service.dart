import 'package:dawarich/application/converters/batch/point_batch_converter.dart';
import 'package:dawarich/application/converters/batch/point_converter.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_dto.dart';
import 'package:dawarich/data_contracts/interfaces/point_creation_repository_interfaces.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point_batch.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/point.dart';
import 'package:flutter/cupertino.dart';
import 'package:option_result/option_result.dart';

class PointCreationService {

  final IPointCreationInterfaces _pointCreationInterfaces;

  PointCreationService(this._pointCreationInterfaces);

  Future<Result<Point, String>> createPoint() async {

    Result<PointDto, String> creationResult = await _pointCreationInterfaces.createPoint();

    switch (creationResult) {
      case Ok(value: PointDto pointDto): {
        Point point = pointDto.toEntity();
        return Ok(point);
      }

      case Err(value: String error): {
        debugPrint(error);
        return Err(error);
      }
    }
  }

  Future<Result<(), String>> uploadBatch() async {

    List<Point> points = [];
    PointBatch batch = PointBatch(points: points);
    return await _pointCreationInterfaces.uploadBatch(batch.toDto());
  }
}