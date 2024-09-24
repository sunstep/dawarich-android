import '../models/api_point.dart';
import '../models/slim_api_point.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PointApi {

  final String _endpoint;
  final String _apiKey;
  final DateTime _startDate;
  final DateTime _endDate;

  const PointApi(this._endpoint, this._apiKey, this._startDate, this._endDate);

  Future<List<ApiPoint>> fetchPoints(int perPage, int page) async {

    final String startDate =
    DateTime(_startDate.year, _startDate.month, _startDate.day)
        .toUtc()
        .toIso8601String();
    final String endDate = DateTime(_endDate.year, _endDate.month,
        _endDate.day, 23, 59, 59)
        .toUtc()
        .toIso8601String();

    final Uri uri = Uri.parse(
        '$_endpoint/api/v1/points?api_key=$_apiKey&start_at=$startDate&end_at=$endDate&per_page=$perPage&page=$page&slim=false');
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData
          .map((point) => ApiPoint(point))
          .toList();
    } else {
      throw Exception('Failed to load points');
    }
  }

  Future<List<SlimApiPoint>> fetchSlimPoints(int perPage, int page) async {
    final String startDate =
    DateTime(_startDate.year, _startDate.month, _startDate.day)
        .toUtc()
        .toIso8601String();
    final String endDate = DateTime(_endDate.year, _endDate.month,
        _endDate.day, 23, 59, 59)
        .toUtc()
        .toIso8601String();

    final Uri uri = Uri.parse(
        '$_endpoint/api/v1/points?api_key=$_apiKey&start_at=$startDate&end_at=$endDate&per_page=$perPage&page=$page&slim=true');
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData
          .map((point) => SlimApiPoint(point))
          .toList();
    } else {
      throw Exception('Failed to load points');
    }
  }

  Future<Map<String, String?>> fetchHeaders(int perPage) async {

    final String startDate =
    DateTime(_startDate.year, _startDate.month, _startDate.day)
        .toUtc()
        .toIso8601String();
    final String endDate = DateTime(_endDate.year, _endDate.month,
        _endDate.day, 23, 59, 59)
        .toUtc()
        .toIso8601String();

    final Uri uri = Uri.parse(
        '$_endpoint/api/v1/points?api_key=$_apiKey&start_at=$startDate&end_at=$endDate&per_page=$perPage');
    final http.Response response = await http.head(uri);

    return response.headers;
  }
}