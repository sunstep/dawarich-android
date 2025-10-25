import 'package:dawarich/features/tracking/data/data_transfer_objects/point/last_point_dto.dart';
import 'package:dawarich/core/point_data/data/data_transfer_objects/local/local_point_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class IPointLocalRepository {
  Future<int> storePoint(LocalPointDto point);
  Future<List<LocalPointDto>> getFullBatch(int userId);
  Future<List<LocalPointDto>> getCurrentBatch(int userId);
  Stream<List<LocalPointDto>> watchCurrentBatch(int userId);
  Future<Option<LastPointDto>> getLastPoint(int userId);
  Stream<Option<LastPointDto>> watchLastPoint(int userId);
  Future<int> getBatchPointCount(int userId);
  Stream<int> watchBatchPointCount(int userId);
  Future<int> markBatchAsUploaded(int userId, List<int> pointIds);
  Future<int> deletePoints(int userId, List<int> pointIds);
  Future<int> clearBatch(int userId);
}
