import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/point/last_point_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class IPointLocalRepository {
  Future<int> storePoint(LocalPointDto point);
  Future<List<LocalPointDto>> getFullBatch(int userId);
  Future<List<LocalPointDto>> getCurrentBatch(int userId);
  Future<Option<LastPointDto>> getLastPoint(int userId);
  Future<int> getBatchPointCount(int userId);
  Future<int> markBatchAsUploaded(int userId);
  Future<int> deletePoint(int userId, int pointId);
  Future<int> clearBatch(int userId);
}
