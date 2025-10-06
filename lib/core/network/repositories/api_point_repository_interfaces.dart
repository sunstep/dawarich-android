import 'package:dawarich/core/network/repositories/points_order.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/point/upload/dawarich_point_batch_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/api/api_point_dto.dart';
import 'package:dawarich/features/timeline/data_contracts/data_transfer_objects/slim_api_point_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class IApiPointRepository {
  Future<Result<(), String>> uploadBatch(DawarichPointBatchDto batch);
  Future<Option<List<ApiPointDTO>>> getPoints({
    required DateTime startDate,
    required DateTime endDate,
    required int perPage,
    PointsOrder order = PointsOrder.descending
  });
  Future<Option<List<SlimApiPointDTO>>> getSlimPoints({
    required DateTime startDate,
    required DateTime endDate,
    required int perPage,
    PointsOrder order = PointsOrder.descending
  });
  Future<int> getTotalPages({required DateTime startDate, required DateTime endDate, required int perPage});
  Future<Option<ApiPointDTO>> fetchLastPoint({DateTime? start, DateTime? end});
  Future<Option<SlimApiPointDTO>> fetchLastSlimPoint({
    DateTime? start,
    DateTime? end
  });
  Future<Option<SlimApiPointDTO>> fetchLastSlimPointForDay(DateTime day);
  Future<Result<(), String>> deletePoint(String point);
}
