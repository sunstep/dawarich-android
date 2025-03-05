import 'package:dawarich/data_contracts/data_transfer_objects/local/last_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class ILocalPointRepository {

  Future<Result<void, String>> storePoint(LocalPointDto point);
  Future<Option<LastPointDto>> getLastPoint();
  Future<Result<LocalPointBatchDto, String>> getFullBatch();
  Future<Result<LocalPointBatchDto, String>> getCurrentBatch();
  Future<Result<int, String>> getBatchPointCount();
  Future<Result<int, String>> markBatchAsUploaded(List<int> batchIds);
  Future<Result<void, String>> deletePoint(int pointId);
  Future<Result<void, String>> clearBatch();
}