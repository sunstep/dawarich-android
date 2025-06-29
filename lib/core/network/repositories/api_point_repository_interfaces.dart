import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/point/upload/dawarich_point_batch_dto.dart';
import 'package:dawarich/core/point_data/data_transfer_objects/api/api_point_dto.dart';
import 'package:dawarich/features/timeline/data_contracts/data_transfer_objects/slim_api_point_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class IApiPointRepository {
  Future<Result<(), String>> uploadBatch(DawarichPointBatchDto batch);
  Future<Option<List<ApiPointDTO>>> fetchPoints(
      DateTime startDate, DateTime endDate, int perPage);
  Future<Option<List<SlimApiPointDTO>>> fetchSlimPoints(
      DateTime startDate, DateTime endDate, int perPage);
  Future<int> getTotalPages(DateTime startDate, DateTime endDate, int perPage);
  Future<Option<ApiPointDTO>> fetchLastPoint();
  Future<Result<(), String>> deletePoint(String point);
}
