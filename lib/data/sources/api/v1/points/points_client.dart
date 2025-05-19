import 'package:dawarich/data/sources/local/secure_storage/api_config_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/api_config_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/received_api_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/slim_api_point_dto.dart';
import 'package:http/http.dart' as http;
import 'package:option_result/option_result.dart';
import 'dart:convert';

final class PointsClient {

  final ApiConfigClient _apiConfig;
  late ApiConfigDTO _apiInfo;

  PointsClient(this._apiConfig){
    ApiConfigDTO? apiInfo = _apiConfig.getApiConfig();

    if (!apiInfo.isConfigured()) {
      throw StateError("Cannot query points without a configured endpoint");
    }
    _apiInfo = apiInfo;
  }

  Future<Result<List<ReceivedApiPointDTO>, String>> getPoints(String startDate, String endDate, int perPage, int page) async {

    final Uri uri = Uri.parse(
        '${_apiInfo.host}/api/v1/points?api_key=${_apiInfo.apiKey}&start_at=$startDate&end_at=$endDate&per_page=$perPage&page=$page');
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return Ok(responseData
          .map((point) => ReceivedApiPointDTO(point))
          .toList());
    }

    return Err(response.reasonPhrase != null ? response.reasonPhrase! : "An unexpected error has occurred while querying points.");
  }

  Future<Result<List<SlimApiPointDTO>, String>> getSlimPoints(String startDate, String endDate, int perPage, int page) async {
    final Uri uri = Uri.parse(
        '${_apiInfo.host}/api/v1/points?api_key=${_apiInfo.apiKey}&start_at=$startDate&end_at=$endDate&per_page=$perPage&page=$page&slim=true');
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return Ok(responseData
          .map((point) => SlimApiPointDTO(point as Map<String, dynamic>))
          .toList());
    }

    return Err(response.reasonPhrase != null ? response.reasonPhrase! : "An unexpected error has occurred while querying slim points.");
  }

  Future<Result<ReceivedApiPointDTO, String>> getLastPoint() async {
    final Uri uri = Uri.parse("${_apiInfo.host}/api/v1/points?api_key=${_apiInfo.apiKey}&per_page=1&page=1&order=desc");
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);
      return Ok(ReceivedApiPointDTO(responseData));
    }

    return Err(response.reasonPhrase != null ? response.reasonPhrase! : "An unexpected error has occurred while retrieving last point.");

  }

  Future<Result<Map<String, String?>, String>> getHeaders(String startDate, String endDate, int perPage) async {

    final Uri uri = Uri.parse(
        '${_apiInfo.host}/api/v1/points?api_key=${_apiInfo.apiKey}&start_at=$startDate&end_at=$endDate&per_page=$perPage');
    final http.Response response = await http.head(uri);

    if (response.statusCode == 200) {
      return Ok(response.headers);
    }

    return Err(response.reasonPhrase != null ? response.reasonPhrase! : "An unexpected error has occurred while retrieving last point.");
  }

  Future<Result<(), String>> getDeletePoint(String id) async {
    final Uri uri = Uri.parse(
      "${_apiInfo.host}/api/v1/points/$id?api_key=${_apiInfo.apiKey}",
    );

    try {
      final http.Response response = await http.delete(uri);

      if (response.statusCode == 200) {
        return const Ok(());
      } else {
        return Err("Failed to delete point: Http error ${response.statusCode}, ${response.reasonPhrase}");
      }
    } catch (error) {
      return Err("Error during API call: $error");
    }
  }
}
