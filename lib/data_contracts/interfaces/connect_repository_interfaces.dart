import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class IConnectRepository {
  Future<bool> testHost(String host);
  Future<Result<UserDto, String>> loginApiKey(String apiKey);
}
