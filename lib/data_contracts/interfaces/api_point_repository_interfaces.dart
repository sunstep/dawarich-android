import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/api_point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/received_api_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/slim_api_point_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class IApiPointInterfaces {

  Future<Result<void, String>> uploadBatch(ApiPointBatchDto batch);
  Future<Option<List<ReceivedApiPointDTO>>> fetchAllPoints(DateTime startDate, DateTime endDate, int perPage);
  Future<Option<List<SlimApiPointDTO>>> fetchAllSlimPoints(DateTime startDate, DateTime endDate, int perPage);
  Future<int> getTotalPages(DateTime startDate, DateTime endDate, int perPage);
  Future<Option<ReceivedApiPointDTO>> fetchLastPoint();
  Future<Option<Map<String, String?>>> fetchHeaders(DateTime startDate, DateTime endDate, int perPage);
  Future<Result<(), String>> deletePoint(String point);
}