
import 'dart:convert';

import 'package:dawarich/domain/data_transfer_objects/api/v1/overland/batches/request/batch_dto.dart';
import 'package:dawarich/domain/data_transfer_objects/local/api_config_dto.dart';
import 'package:dawarich/domain/interfaces/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:option_result/option_result.dart';

class BatchesWrapper {

  final IApiConfigSource _apiConfig;
  late ApiConfigDTO _apiInfo;

  BatchesWrapper(this._apiConfig) {
    ApiConfigDTO? apiInfo = _apiConfig.getApiConfig();

    if (!apiInfo.isConfigured()) {
      throw StateError("Cannot query points without a configured endpoint");
    }
    _apiInfo = apiInfo;
  }

  Future<Result<(), String>> post(BatchDto batch) async {

    final Uri url = Uri.parse("${_apiInfo.host}/api/v1/overland/batches?api_key=${_apiInfo.apiKey}");
    final http.Response response = await http.post(url, body: batch);

    if (response.statusCode == 201) {
      final dynamic responseBody = jsonDecode(response.body);

      return const Ok(());
    }

    return Err(response.reasonPhrase != null ? response.reasonPhrase! : "An unexpected error has occurred while uploading point batch.");
  }
}