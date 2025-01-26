import 'package:dawarich/data/sources/local/secure_storage/api_config_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/api_config_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/stats/response/stats_dto.dart';
import 'package:http/http.dart';
import 'package:option_result/option_result.dart';
import 'dart:convert';


class StatsClient {

  final ApiConfigClient _apiConfig;
  late ApiConfigDTO _apiInfo;

  StatsClient(this._apiConfig){
    ApiConfigDTO? apiInfo = _apiConfig.getApiConfig();

    if (!apiInfo.isConfigured()) {
      throw StateError("Cannot query stats without a configured endpoint");
    }
    _apiInfo = apiInfo;
  }

  Future<Result<StatsDTO, String>> queryStats() async {

    final Uri uri = Uri.parse(
        '${_apiInfo.host}/api/v1/stats?api_key=${_apiInfo.apiKey}');
    final Response response = await get(uri);

    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);
      final StatsDTO stats = StatsDTO.fromJson(responseData);
      return Ok(stats);
    }

    return Err(response.reasonPhrase != null ? "Failed to query stats: ${response.reasonPhrase}" : "An unexpected error has occurred while querying stats.");
  }


}