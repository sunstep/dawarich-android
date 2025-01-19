
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/api_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/slim_api_point_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class IPointInterfaces {

  Future<Result<PointDto, String>> createPoint();
  Future<Option<PointDto>> createCachedPoint();
  Future<Result<(), String>> uploadBatch(PointBatchDto batch);
  Future<Option<List<ApiPointDTO>>> fetchAllPoints(DateTime startDate, DateTime endDate, int perPage);
  Future<Option<List<SlimApiPointDTO>>> fetchAllSlimPoints(DateTime startDate, DateTime endDate, int perPage);
  Future<int> getTotalPages(DateTime startDate, DateTime endDate, int perPage);
  Future<Option<ApiPointDTO>> fetchLastPoint();
  Future<Option<Map<String, String?>>> fetchHeaders(DateTime startDate, DateTime endDate, int perPage);
  Future<Result<(), String>> deletePoints(String point);
}