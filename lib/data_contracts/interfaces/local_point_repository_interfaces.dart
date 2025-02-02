import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/api_batch_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/database/batch/batch_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/database/batch/point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/last_point_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class ILocalPointInterfaces {

  Future<Result<ApiBatchPointDto, String>> createPoint();
  Future<Option<ApiBatchPointDto>> createCachedPoint();
  Future<Result<void, String>> storePoint(ApiBatchPointDto point);
  Future<Option<LastPointDto>> getLastPoint();
  Future<PointBatchDto> getCurrentBatch();
  Future<int> getBatchPointCount();
  Future<bool> isDuplicatePoint(BatchPointDto point);
  Future<Result<int, String>> markBatchAsUploaded(List<int> batchIds);
  Future<Result<void, String>> deletePoint(int pointId);
  Future<Result<void, String>> clearBatch();
}