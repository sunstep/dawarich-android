import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/request/dawarich_point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/api_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/slim_api_point_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class IApiPointRepository {
  Future<Result<(), String>> uploadBatch(DawarichPointBatchDto batch);
  Future<Option<List<ApiPointDTO>>> fetchAllPoints(
      DateTime startDate, DateTime endDate, int perPage);
  Future<Option<List<SlimApiPointDTO>>> fetchAllSlimPoints(
      DateTime startDate, DateTime endDate, int perPage);
  Future<int> getTotalPages(DateTime startDate, DateTime endDate, int perPage);
  Future<Option<ApiPointDTO>> fetchLastPoint();
  Future<Result<(), String>> deletePoint(String point);
}
