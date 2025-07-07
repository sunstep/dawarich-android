

import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/auth/application/user_converter.dart';
import 'package:dawarich/features/auth/data_contracts/data_transfer_objects/users/user_dto.dart';
import 'package:dawarich/features/auth/data_contracts/interfaces/user_repository_interfaces.dart';
import 'package:option_result/option_result.dart';
import 'package:session_box/session_box.dart';

final class AuthService {

  final IUserRepository _userRepository;
  AuthService(this._userRepository);

  /// Used by the session box package to validate if the user still exists (and to refresh the user id in memory)
  Future<bool> isValidUser(User sessionUser) async {
    final Option<UserDto> result = await _userRepository.getUserByEmail(
      sessionUser.dawarichHost,
      sessionUser.email,
    );

    return result is Some;
  }

  /// Retrieves the full User (from DB) by identity from session
  Future<Option<User>> getUserByHostAndEmail(String? host, String email) async {
    final Option<UserDto> result = await _userRepository.getUserByEmail(host, email);

    return result.map((dto) => dto.toDomain());
  }
}