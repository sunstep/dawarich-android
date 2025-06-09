import 'package:dawarich/data_contracts/data_transfer_objects/local/api_config_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/stats/response/stats_dto.dart';
import 'package:dawarich/data_contracts/interfaces/api_config_repository_interfaces.dart';
import 'package:http/http.dart';
import 'package:option_result/option_result.dart';
import 'dart:convert';

final class StatsClient {
  final IApiConfigRepository _apiConfig;

  StatsClient(this._apiConfig);

  Future<Result<StatsDTO, String>> queryStats() async {
    ApiConfigDTO? apiInfo = _apiConfig.getApiConfig();

    if (apiInfo == null || !apiInfo.isComplete) {
      throw Exception(
          "[StatsClient] Cannot approach API without a complete config");
    }

    final Uri uri =
        Uri.parse('${apiInfo.host}/api/v1/stats?api_key=${apiInfo.apiKey}');
    final Response response = await get(uri);

    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);
      final StatsDTO stats = StatsDTO.fromJson(responseData);
      return Ok(stats);
    }

    return Err(response.reasonPhrase != null
        ? "Failed to query stats: ${response.reasonPhrase}"
        : "An unexpected error has occurred while querying stats.");
  }
}
