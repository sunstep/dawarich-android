import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/request/dawarich_point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/api_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/slim_api_point_dto.dart';
import 'package:dawarich/data_contracts/interfaces/api_point_repository_interfaces.dart';
import 'package:option_result/option_result.dart';

final class ApiPointRepositoryMock implements IApiPointRepository {
  bool shouldUploadFail = false;
  bool shouldFetchHeadersFail = false;
  bool shouldFetchPointsFail = false;
  bool shouldFetchSlimFail = false;
  bool shouldFetchLastFail = false;
  bool shouldDeleteFail = false;

  Map<String, String?> stubHeaders = {'x-total-pages': '1'};
  List<ApiPointDTO> stubPoints = [];
  List<SlimApiPointDTO> stubSlimPoints = [];
  ApiPointDTO? stubLastPoint;

  int uploadBatchCallCount = 0;
  DawarichPointBatchDto? lastUploadedBatch;

  int fetchHeadersCallCount = 0;
  DateTime? lastFetchHeadersStart;
  DateTime? lastFetchHeadersEnd;
  int? lastFetchHeadersPerPage;

  int fetchAllPointsCallCount = 0;
  DateTime? lastFetchPointsStart;
  DateTime? lastFetchPointsEnd;
  int? lastFetchPointsPerPage;

  int fetchAllSlimCallCount = 0;
  DateTime? lastFetchSlimStart;
  DateTime? lastFetchSlimEnd;
  int? lastFetchSlimPerPage;

  int getTotalPagesCallCount = 0;
  DateTime? lastGetTotalPagesStart;
  DateTime? lastGetTotalPagesEnd;
  int? lastGetTotalPagesPerPage;

  int fetchLastPointCallCount = 0;

  int deletePointCallCount = 0;
  String? lastDeletedPointId;

  @override
  Future<Result<(), String>> uploadBatch(DawarichPointBatchDto batch) async {
    uploadBatchCallCount++;
    lastUploadedBatch = batch;
    if (shouldUploadFail) return const Err('upload failed');
    return const Ok(());
  }

  @override
  Future<Option<Map<String, String?>>> fetchHeaders(
      DateTime start, DateTime end, int perPage) async {
    fetchHeadersCallCount++;
    lastFetchHeadersStart = start;
    lastFetchHeadersEnd = end;
    lastFetchHeadersPerPage = perPage;

    if (shouldFetchHeadersFail) return const None();
    return Some(stubHeaders);
  }

  @override
  Future<Option<List<ApiPointDTO>>> fetchAllPoints(
      DateTime start, DateTime end, int perPage) async {
    fetchAllPointsCallCount++;
    lastFetchPointsStart = start;
    lastFetchPointsEnd = end;
    lastFetchPointsPerPage = perPage;

    if (shouldFetchPointsFail) return const None();
    return Some(stubPoints);
  }

  @override
  Future<Option<List<SlimApiPointDTO>>> fetchAllSlimPoints(
      DateTime start, DateTime end, int perPage) async {
    fetchAllSlimCallCount++;
    lastFetchSlimStart = start;
    lastFetchSlimEnd = end;
    lastFetchSlimPerPage = perPage;

    if (shouldFetchSlimFail) return const None();
    return Some(stubSlimPoints);
  }

  @override
  Future<int> getTotalPages(DateTime start, DateTime end, int perPage) async {
    getTotalPagesCallCount++;
    lastGetTotalPagesStart = start;
    lastGetTotalPagesEnd = end;
    lastGetTotalPagesPerPage = perPage;

    if (shouldFetchHeadersFail) return 0;
    return int.parse(stubHeaders['x-total-pages']!);
  }

  @override
  Future<Option<ApiPointDTO>> fetchLastPoint() async {
    fetchLastPointCallCount++;
    if (shouldFetchLastFail || stubLastPoint == null) return const None();
    return Some(stubLastPoint!);
  }

  @override
  Future<Result<(), String>> deletePoint(String id) async {
    deletePointCallCount++;
    lastDeletedPointId = id;
    if (shouldDeleteFail) return const Err('delete failed');
    return const Ok(());
  }
}
