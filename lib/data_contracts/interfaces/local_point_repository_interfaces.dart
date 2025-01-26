
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class ILocalPointInterfaces {

  Future<Result<PointDto, String>> createPoint();
  Future<Option<PointDto>> createCachedPoint();
  Future<Result<void, String>> storePoint(PointDto point);
  Future<Result<void, String>> uploadBatch(PointBatchDto batch);
  Future<int> getBatchPointCount();
  Future<bool> isDuplicatePoint(PointDto point);
}