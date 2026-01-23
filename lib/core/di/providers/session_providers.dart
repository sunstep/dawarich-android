import 'package:dawarich/core/di/providers/user_providers.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/auth/application/repositories/user_repository_interfaces.dart';
import 'package:dawarich/features/auth/application/usecases/validate_user_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:session_box/session_box.dart';


final validateUserUseCaseProvider = FutureProvider<ValidateUserUseCase>((ref) async {
  final IUserRepository userRepository = await ref.watch(userRepositoryProvider.future);
  return ValidateUserUseCase(userRepository);
});


final sessionBoxProvider = FutureProvider<SessionBox<User>>((ref) async {

  final validateUser = await ref.watch(validateUserUseCaseProvider.future);

  final box = await SessionBox.create<User>(
    encrypt: false,
    toJson: (user) => user.toJson(),
    fromJson: (json) => User.fromJson(json),
    isValidUser: (user) => validateUser(user),
  );

  return box;
});