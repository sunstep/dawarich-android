import 'package:dawarich/features/auth/data/data_transfer_objects/users/user_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class IConnectRepository {
  Future<bool> testHost(String host);
  Future<Result<UserDto, String>> loginApiKey(String apiKey);
}
