import 'package:dawarich/data_contracts/data_transfer_objects/local/last_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class ILocalPointRepository {
  Future<Result<(), String>> storePoint(LocalPointDto point);
  Future<Option<LastPointDto>> getLastPoint(int userId);
  Future<Result<LocalPointBatchDto, String>> getFullBatch(int userId);
  Future<Result<LocalPointBatchDto, String>> getCurrentBatch(int userId);
  Future<Result<int, String>> getBatchPointCount(int userId);
  Future<Result<int, String>> markBatchAsUploaded(
      List<int> batchIds, int userId);
  Future<Result<(), String>> deletePoint(int pointId, int userId);
  Future<Result<(), String>> clearBatch(int userId);
}
