import 'package:dawarich/data_contracts/data_transfer_objects/local/api_config_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/stats/response/stats_dto.dart';
import 'package:dawarich/data_contracts/interfaces/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:option_result/option_result.dart';
import 'dart:convert';


class StatsSource {

  final IApiConfigSource _apiConfig;
  late ApiConfigDTO _apiInfo;

  StatsSource(this._apiConfig){
    ApiConfigDTO? apiInfo = _apiConfig.getApiConfig();

    if (!apiInfo.isConfigured()) {
      throw StateError("Cannot query stats without a configured endpoint");
    }
    _apiInfo = apiInfo;
  }

  Future<Result<StatsDTO, String>> queryStats() async {

    final Uri uri = Uri.parse(
        '${_apiInfo.host}/api/v1/stats?api_key=${_apiInfo.apiKey}');
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);
      final StatsDTO stats = StatsDTO.fromJson(responseData);
      return Ok(stats);
    }

    return Err(response.reasonPhrase != null ? "Failed to query stats: ${response.reasonPhrase}" : "An unexpected error has occurred while querying stats.");
  }


}