import 'dart:convert';

import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/api_config_dto.dart';
import 'package:dawarich/data_contracts/interfaces/api_config_repository_interfaces.dart';
import 'package:http/http.dart';
import 'package:option_result/option_result.dart';

final class UsersApiClient {

  final IApiConfigRepository _apiConfig;
  late ApiConfigDTO _apiInfo;

  UsersApiClient(this._apiConfig){
    ApiConfigDTO? apiInfo = _apiConfig.getApiConfig();

    if (apiInfo == null || !apiInfo.isComplete) {
      throw Exception("[UsersClient] Cannot approach API without a complete configuration");
    }
    _apiInfo = apiInfo;
  }

  Future<Result<UserDto, String>> getUser() async {

    final Uri uri = Uri.parse("${_apiInfo.host}/api/v1/users/me");
    Map<String, String> headers = {
      "Authorization": "Bearer ${_apiInfo.apiKey}"
    };

    try {

      if (_apiInfo.host != null && _apiInfo.apiKey != null) {
        final Response response = await get(uri, headers: headers);

        if (response.statusCode == 200) {
          final Map<String, dynamic> json = jsonDecode(response.body);
          UserDto userDto = UserDto.fromJson(json["user"]);
          UserDto userDtoCopy = userDto.withDawarichEndpoint(_apiInfo.host);
          return Ok(userDtoCopy);
        } else {
          return Err("Failed to fetch user: ${response.statusCode} ${response.reasonPhrase}");
        }
      }

      return const Err("Could not connect to Dawarich: api information missing");

    } catch (e) {
      return Err("Error while fetching user data: $e");
    }

  }


}