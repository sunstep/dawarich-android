

import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/auth/application/repositories/user_repository_interfaces.dart';
import 'package:option_result/option_result.dart';

/// Used by the session box package to validate if the user still exists (and to refresh the user id in memory)
final class ValidateUserUseCase {

  final IUserRepository _userRepository;
  ValidateUserUseCase(this._userRepository);

  Future<bool> call(User sessionUser) async {
    final Option<User> result = await _userRepository.getUserByEmail(
      sessionUser.dawarichHost,
      sessionUser.email,
    );

    return result is Some;
  }

}