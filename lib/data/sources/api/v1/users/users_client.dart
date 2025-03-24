import 'dart:convert';

import 'package:dawarich/data/sources/local/secure_storage/api_config_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/api_config_dto.dart';
import 'package:http/http.dart';
import 'package:option_result/option_result.dart';

class UsersApiClient {

  ApiConfigClient _apiConfigClient;
  late ApiConfigDTO _apiInfo;

  UsersApiClient(this._apiConfigClient);

  void setApiConfigClient(ApiConfigClient client) {
    _apiConfigClient = client;
  }

  Future<Result<UserDto, String>> getUser() async {

    _apiInfo = _apiConfigClient.getApiConfig();

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
          userDto.setDawarichEndpoint(_apiInfo.host);
          return Ok(userDto);
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