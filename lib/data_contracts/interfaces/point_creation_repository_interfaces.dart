
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class IPointCreationInterfaces {

  Future<Result<PointDto, String>> createPoint();
  Future<Option<PointDto>> createCachedPoint();
  Future<Result<(), String>> uploadBatch(PointBatchDto batch);
}