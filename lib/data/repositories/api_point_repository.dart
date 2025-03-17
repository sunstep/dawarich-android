import 'package:dawarich/data/sources/api/v1/overland/batches/batches_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/request/dawarich_point_batch_dto.dart';
import 'package:dawarich/data_contracts/interfaces/api_point_repository_interfaces.dart';
import 'package:dawarich/data/sources/api/v1/points/points_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/received_api_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/slim_api_point_dto.dart';
import 'package:flutter/cupertino.dart';
import 'package:option_result/option_result.dart';


class ApiPointRepository implements IApiPointInterfaces {

  final PointsClient _pointsClient;
  final BatchesClient _batchesClient;
  ApiPointRepository(this._pointsClient, this._batchesClient);

  @override
  Future<Result<(), String>> uploadBatch(DawarichPointBatchDto batch) async {

    Result<dynamic, String> result = await _batchesClient.post(batch);

    switch (result) {

      case Ok(value: dynamic _): {
        return const Ok(());
      }

      case Err(value: String error): {
        return Err(error);
      }
    }


  }

  @override
  Future<Option<List<ReceivedApiPointDTO>>> fetchAllPoints(DateTime startDate, DateTime endDate, int perPage) async {

    final String startDateString = _formatStartDate(startDate);
    final String endDateString = _formatEndDate(endDate);

    Result<Map<String, String?>, String> headerResult = await _pointsClient.getHeaders(startDateString, endDateString, perPage);

    switch (headerResult) {

      case Ok(value: Map<String, String?> headers): {
        int pages = int.parse(headers['x-total-pages']!);
        final List<ReceivedApiPointDTO> allPoints = [];

        final List<Future<Result<List<ReceivedApiPointDTO>, String>>> responses = [];
        for (int page = 1; page <= pages; page++) {
          responses.add(_pointsClient.getPoints(startDateString, endDateString, perPage, page));
        }

        final List<Result<List<ReceivedApiPointDTO>, String>> fetchResults = await Future.wait(responses);
        for (final Result<List<ReceivedApiPointDTO>, String> fetchResult in fetchResults) {

          switch (fetchResult){
            case Ok(value: List<ReceivedApiPointDTO> page): {
              allPoints.addAll(page);
            }
            case Err(value: String error): {
              debugPrint('Error fetching points for a page: $error');
            }
          }

        }

        return Some(allPoints);
      }

      case Err(value: String error): {
        debugPrint("Failed to retrieve headers: $error");
        return const None();
      }
    }

  }

  @override
  Future<Option<List<SlimApiPointDTO>>> fetchAllSlimPoints(DateTime startDate, DateTime endDate, int perPage) async {

    final String startDateString = _formatStartDate(startDate);
    final String endDateString = _formatEndDate(endDate);

    Result<Map<String, String?>, String> headerResult = await _pointsClient.getHeaders(startDateString, endDateString, perPage);

    switch (headerResult) {

      case Ok(value: Map<String, String?> headers): {
        int pages = int.parse(headers['x-total-pages']!);
        final List<SlimApiPointDTO> allPoints = [];

        final List<Future<Result<List<SlimApiPointDTO>, String>>> responses = [];
        for (int page = 1; page <= pages; page++) {
          responses.add(_pointsClient.getSlimPoints(startDateString, endDateString, perPage, page));
        }

        final List<Result<List<SlimApiPointDTO>, String>> fetchResults = await Future.wait(responses);
        for (final Result<List<SlimApiPointDTO>, String> fetchResult in fetchResults) {

          switch (fetchResult){
            case Ok(value: List<SlimApiPointDTO> page): {
              allPoints.addAll(page);
            }
            case Err(value: String error): {
              debugPrint('Error fetching slim points for a page: $error');
            }
          }

        }

        return Some(allPoints);
      }

      case Err(value: String error): {
        debugPrint("Failed to retrieve slim point headers: $error");
        return const None();
      }
    }
  }

  @override
  Future<int> getTotalPages(DateTime startDate, DateTime endDate, int perPage) async {

    final String startDateString = _formatStartDate(startDate);
    final String endDateString = _formatEndDate(endDate);


    Result<Map<String, String?>, String> result = await _pointsClient.getHeaders(startDateString, endDateString, perPage);

    switch (result) {

      case Ok(value: Map<String, String?> headers): {
        return int.parse(headers['x-total-pages']!);
      }

      case Err(value: String error): {

        debugPrint("Failed to get total pages: $error");
        return 0;
      }
    }

  }

  @override
  Future<Option<ReceivedApiPointDTO>> fetchLastPoint() async {

    Result<ReceivedApiPointDTO, String> result  = await _pointsClient.getLastPoint();

    switch (result) {

      case Ok(value: ReceivedApiPointDTO dto): return Some(dto);
      case Err(value: String error): {
        debugPrint("Failed to fetch last point: $error");
        return const None();
      }
    }
  }

  @override
  Future<Option<Map<String, String?>>> fetchHeaders(DateTime startDate, DateTime endDate, int perPage) async {

    final String startDateString =
    DateTime(startDate.year, startDate.month, startDate.day)
        .toUtc()
        .toIso8601String();
    final String endDateString = DateTime(startDate.year, startDate.month,
        startDate.day, 23, 59, 59)
        .toUtc()
        .toIso8601String();

    Result<Map<String, String?>, String> result =  await _pointsClient.getHeaders(startDateString, endDateString, perPage);

    switch (result) {

      case Ok(value: Map<String, String?> headers): return Some(headers);
      case Err(value: String error): {

        debugPrint("Failed to fetch headers: $error");
        return const None();
      }
    }
  }

  @override
  Future<Result<(), String>> deletePoint(String point) async {

    Result<(), String> result = await _pointsClient.getDeletePoint(point);

    switch (result)  {

      case Ok(value: ()): return const Ok(());
      case Err(value: String error): {
        debugPrint("Failed to delete point: $error");
        return const Err("Failed to delete point.");
      }
    }
  }

  String _formatStartDate(DateTime date){
    return DateTime(date.year, date.month, date.day)
        .toUtc()
        .toIso8601String();
  }

  String _formatEndDate(DateTime date) {
    return DateTime(date.year, date.month,
        date.day, 23, 59, 59)
        .toUtc()
        .toIso8601String();
  }
}