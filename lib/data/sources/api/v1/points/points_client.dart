import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/request/dawarich_point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/api_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/api_config_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/slim_api_point_dto.dart';
import 'package:dawarich/data_contracts/interfaces/api_config_repository_interfaces.dart';
import 'package:http/http.dart' as http;
import 'package:option_result/option_result.dart';
import 'dart:convert';

final class PointsClient {
  final IApiConfigRepository _apiConfig;
  PointsClient(this._apiConfig);

  Future<Result<(), String>> post(DawarichPointBatchDto batch) async {
    ApiConfigDTO? apiInfo = _apiConfig.getApiConfig();

    if (apiInfo == null || !apiInfo.isComplete) {
      throw Exception("Cannot approach API without a complete api config");
    }

    final Uri uri =
        Uri.parse("${apiInfo.host}/api/v1/points&api_key=${apiInfo.apiKey}");

    final String body = jsonEncode(batch);

    final http.Response response = await http.post(uri, body: body);

    if (response.statusCode == 201) {
      final dynamic _ = jsonDecode(response.body);

      return const Ok(());
    }

    return Err(response.reasonPhrase != null
        ? response.reasonPhrase!
        : "An unexpected error has occurred while uploading point batch.");
  }

  Future<Result<List<ApiPointDTO>, String>> getPoints(
      String startDate, String endDate, int perPage, int page) async {
    ApiConfigDTO? apiInfo = _apiConfig.getApiConfig();

    if (apiInfo == null || !apiInfo.isComplete) {
      throw Exception("Cannot approach API without a complete api config");
    }

    final Uri uri = Uri.parse(
        '${apiInfo.host}/api/v1/points?api_key=${apiInfo.apiKey}&start_at=$startDate&end_at=$endDate&per_page=$perPage&page=$page');
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return Ok(responseData.map((point) => ApiPointDTO(point)).toList());
    }

    return Err(response.reasonPhrase != null
        ? response.reasonPhrase!
        : "An unexpected error has occurred while querying points.");
  }

  Future<Result<List<SlimApiPointDTO>, String>> getSlimPoints(
      String startDate, String endDate, int perPage, int page) async {
    ApiConfigDTO? apiInfo = _apiConfig.getApiConfig();

    if (apiInfo == null || !apiInfo.isComplete) {
      throw Exception("Cannot approach API without a complete api config");
    }

    final Uri uri = Uri.parse(
        '${apiInfo.host}/api/v1/points?api_key=${apiInfo.apiKey}&start_at=$startDate&end_at=$endDate&per_page=$perPage&page=$page&slim=true');
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return Ok(responseData
          .map((point) => SlimApiPointDTO(point as Map<String, dynamic>))
          .toList());
    }

    return Err(response.reasonPhrase != null
        ? response.reasonPhrase!
        : "An unexpected error has occurred while querying slim points.");
  }

  Future<Result<ApiPointDTO, String>> getLastPoint() async {
    ApiConfigDTO? apiInfo = _apiConfig.getApiConfig();

    if (apiInfo == null || !apiInfo.isComplete) {
      throw Exception("Cannot approach API without a complete api config");
    }

    final Uri uri = Uri.parse(
        "${apiInfo.host}/api/v1/points?api_key=${apiInfo.apiKey}&per_page=1&page=1&order=desc");
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);
      return Ok(ApiPointDTO(responseData));
    }

    return Err(response.reasonPhrase != null
        ? response.reasonPhrase!
        : "An unexpected error has occurred while retrieving last point.");
  }

  Future<Result<Map<String, String?>, String>> getHeaders(
      String startDate, String endDate, int perPage) async {
    ApiConfigDTO? apiInfo = _apiConfig.getApiConfig();

    if (apiInfo == null || !apiInfo.isComplete) {
      throw Exception("Cannot approach API without a complete api config");
    }

    final Uri uri = Uri.parse(
        '${apiInfo.host}/api/v1/points?api_key=${apiInfo.apiKey}&start_at=$startDate&end_at=$endDate&per_page=$perPage');
    final http.Response response = await http.head(uri);

    if (response.statusCode == 200) {
      return Ok(response.headers);
    }

    return Err(response.reasonPhrase != null
        ? response.reasonPhrase!
        : "An unexpected error has occurred while retrieving last point.");
  }

  Future<Result<(), String>> deletePoint(String id) async {
    ApiConfigDTO? apiInfo = _apiConfig.getApiConfig();

    if (apiInfo == null || !apiInfo.isComplete) {
      throw Exception("Cannot approach API without a complete api config");
    }

    final Uri uri = Uri.parse(
      "${apiInfo.host}/api/v1/points/$id?api_key=${apiInfo.apiKey}",
    );

    try {
      final http.Response response = await http.delete(uri);

      if (response.statusCode == 200) {
        return const Ok(());
      } else {
        return Err(
            "Failed to delete point: Http error ${response.statusCode}, ${response.reasonPhrase}");
      }
    } catch (error) {
      return Err("Error during API call: $error");
    }
  }
}
