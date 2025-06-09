import 'dart:convert';

import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/api_config_dto.dart';
import 'package:dawarich/data_contracts/interfaces/api_config_repository_interfaces.dart';
import 'package:http/http.dart';
import 'package:option_result/option_result.dart';

final class UsersApiClient {
  final IApiConfigRepository _apiConfig;

  UsersApiClient(this._apiConfig);

  Future<Result<UserDto, String>> getUser() async {
    ApiConfigDTO? apiInfo = _apiConfig.getApiConfig();

    if (apiInfo == null || !apiInfo.isComplete) {
      throw Exception(
          "[UsersClient] Cannot approach API without a complete configuration");
    }

    final Uri uri = Uri.parse("${apiInfo.host}/api/v1/users/me");
    Map<String, String> headers = {"Authorization": "Bearer ${apiInfo.apiKey}"};

    try {
      final Response response = await get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        UserDto userDto = UserDto.fromJson(json["user"]);
        UserDto userDtoCopy = userDto.withDawarichEndpoint(apiInfo.host);
        return Ok(userDtoCopy);
      } else {
        return Err(
            "Failed to fetch user: ${response.statusCode} ${response.reasonPhrase}");
      }
    } catch (e) {
      return Err("Error while fetching user data: $e");
    }
  }
}
