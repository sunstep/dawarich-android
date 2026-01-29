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

  ref.keepAlive();

  final validateUser = await ref.watch(validateUserUseCaseProvider.future);

  final box = await SessionBox.create<User>(
    encrypt: false,
    toJson: (user) => user.toJson(),
    fromJson: (json) => User.fromJson(json),
    isValidUser: (user) => validateUser(user),
  );

  return box;
});

/// Holds the currently authenticated user.
/// Set by AuthGuard when navigating to protected routes.
/// In protected contexts, this is guaranteed to be non-null.
final authenticatedUserProvider = NotifierProvider<AuthenticatedUserNotifier, User?>(() => AuthenticatedUserNotifier());

class AuthenticatedUserNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void setUser(User? user) {
    state = user;
  }
}

