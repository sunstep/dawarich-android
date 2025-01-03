import 'package:dawarich/domain/data_transfer_objects/api/points/response/api_point_dto.dart';
import 'package:dawarich/domain/data_transfer_objects/api/points/response/slim_api_point_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class IPointInterfaces {

  Future<Option<List<ApiPointDTO>>> fetchAllPoints(DateTime startDate, DateTime endDate, int perPage);
  Future<Option<List<SlimApiPointDTO>>> fetchAllSlimPoints(DateTime startDate, DateTime endDate, int perPage);
  Future<int> getTotalPages(DateTime startDate, DateTime endDate, int perPage);
  Future<Option<ApiPointDTO>> fetchLastPoint();
  Future<Option<Map<String, String?>>> fetchHeaders(DateTime startDate, DateTime endDate, int perPage);
  Future<Result<(), String>> deletePoints(String point);
}