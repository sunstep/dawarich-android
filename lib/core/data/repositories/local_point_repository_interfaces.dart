import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/domain/models/last_point.dart';
import 'package:option_result/option_result.dart';

abstract interface class IPointLocalRepository {
  Future<int> storePoint(LocalPoint point);
  Future<List<LocalPoint>> getFullBatch(int userId);
  Future<List<LocalPoint>> getCurrentBatch(int userId);
  Stream<List<LocalPoint>> watchCurrentBatch(int userId);
  Future<Option<LastPoint>> getLastPoint(int userId);
  Stream<Option<LastPoint>> watchLastPoint(int userId);
  Future<int> getBatchPointCount(int userId);
  Stream<int> watchBatchPointCount(int userId);
  Future<int> markBatchAsUploaded(int userId, List<int> pointIds);
  Future<int> deletePoints(int userId, List<int> pointIds);
  Future<int> clearBatch(int userId);

  /// Deletes all uploaded points except the most recent one.
  /// The last point is kept (marked as uploaded) for validation reference.
  Future<int> deleteUploadedPointsExceptLast(int userId);
}
