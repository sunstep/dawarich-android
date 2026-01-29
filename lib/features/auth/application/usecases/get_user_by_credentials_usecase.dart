
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/auth/application/repositories/user_repository_interfaces.dart';
import 'package:option_result/option_result.dart';

/// Retrieves the full User (from DB) by identity from session
final class GetUserByCredentialsUseCase {

  final IUserRepository _userRepository;
  GetUserByCredentialsUseCase(this._userRepository);

  Future<Option<User>> call(String? host, String email) async {
    final Option<User> result = await _userRepository.getUserByEmail(host, email);

    return result;
  }

}