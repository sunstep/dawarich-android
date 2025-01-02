import 'package:dawarich/domain/interfaces/point_interfaces.dart';
import 'package:dawarich/data/sources/api/points/point_source.dart';
import 'package:dawarich/domain/data_transfer_objects/api/points/api_point_dto.dart';
import 'package:dawarich/domain/data_transfer_objects/api/points/slim_api_point_dto.dart';
import 'package:flutter/cupertino.dart';
import 'package:option_result/option_result.dart';


class PointRepository implements IPointInterfaces {

  final PointSource _source;
  PointRepository(this._source);

  @override
  Future<Option<List<ApiPointDTO>>> fetchAllPoints(DateTime startDate, DateTime endDate, int perPage) async {

    final String startDateString = _formatStartDate(startDate);
    final String endDateString = _formatEndDate(endDate);

    Result<Map<String, String?>, String> headerResult = await _source.queryHeaders(startDateString, endDateString, perPage);

    switch (headerResult) {

      case Ok(value: Map<String, String?> headers): {
        int pages = int.parse(headers['x-total-pages']!);
        final List<ApiPointDTO> allPoints = [];

        final List<Future<Result<List<ApiPointDTO>, String>>> responses = [];
        for (int page = 1; page <= pages; page++) {
          responses.add(_source.queryPoints(startDateString, endDateString, perPage, page));
        }

        final List<Result<List<ApiPointDTO>, String>> fetchResults = await Future.wait(responses);
        for (final Result<List<ApiPointDTO>, String> fetchResult in fetchResults) {

          switch (fetchResult){
            case Ok(value: List<ApiPointDTO> page): {
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

    Result<Map<String, String?>, String> headerResult = await _source.queryHeaders(startDateString, endDateString, perPage);

    switch (headerResult) {

      case Ok(value: Map<String, String?> headers): {
        int pages = int.parse(headers['x-total-pages']!);
        final List<SlimApiPointDTO> allPoints = [];

        final List<Future<Result<List<SlimApiPointDTO>, String>>> responses = [];
        for (int page = 1; page <= pages; page++) {
          responses.add(_source.querySlimPoints(startDateString, endDateString, perPage, page));
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


    Result<Map<String, String?>, String> result = await _source.queryHeaders(startDateString, endDateString, perPage);

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
  Future<Option<ApiPointDTO>> fetchLastPoint() async {

    Result<ApiPointDTO, String> result  = await _source.queryLastPoint();

    switch (result) {

      case Ok(value: ApiPointDTO dto): return Some(dto);
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

    Result<Map<String, String?>, String> result =  await _source.queryHeaders(startDateString, endDateString, perPage);

    switch (result) {

      case Ok(value: Map<String, String?> headers): return Some(headers);
      case Err(value: String error): {

        debugPrint("Failed to fetch headers: $error");
        return const None();
      }
    }
  }

  @override
  Future<Result<(), String>> deletePoints(String point) async {

    Result<(), String> result = await _source.queryDeletePoint(point);

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