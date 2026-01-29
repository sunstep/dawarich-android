import 'package:dawarich/core/di/providers/core_providers.dart';
import 'package:dawarich/core/di/providers/session_providers.dart';
import 'package:dawarich/core/di/providers/user_providers.dart';
import 'package:dawarich/core/di/providers/version_check_providers.dart';
import 'package:dawarich/features/auth/application/repositories/connect_repository_interfaces.dart';
import 'package:dawarich/features/auth/application/usecases/get_user_by_credentials_usecase.dart';
import 'package:dawarich/features/auth/application/usecases/login_with_api_key_usecase.dart';
import 'package:dawarich/features/auth/application/usecases/test_host_connection_usecase.dart';
import 'package:dawarich/features/auth/application/usecases/validate_user_usecase.dart';
import 'package:dawarich/features/auth/data/repositories/connect_repository.dart';
import 'package:dawarich/features/auth/presentation/viewmodels/auth_page_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectRepositoryProvider = FutureProvider<IConnectRepository>((ref) async {
  final cfg = await ref.watch(apiConfigManagerProvider.future);
  final dio = await ref.watch(dioClientProvider.future);
  return ConnectRepository(cfg, dio);
});

final testHostConnectionUseCaseProvider = FutureProvider<TestHostConnectionUseCase>((ref) async {
  final apiConfigManager = await ref.watch(apiConfigManagerProvider.future);
  final repo = await ref.watch(connectRepositoryProvider.future);
  return TestHostConnectionUseCase(apiConfigManager, repo);
});

final loginWithApiKeyUseCaseProvider = FutureProvider<LoginWithApiKeyUseCase>((ref) async {
  final apiConfigManager = await ref.watch(apiConfigManagerProvider.future);
  final connectRepo = await ref.watch(connectRepositoryProvider.future);
  final userRepo = await ref.watch(userRepositoryProvider.future);
  final sessionBox = await ref.watch(sessionBoxProvider.future);
  return LoginWithApiKeyUseCase(connectRepo, apiConfigManager, userRepo, sessionBox);
});

final validateUserUseCaseProvider = FutureProvider<ValidateUserUseCase>((ref) async {
  final userRepo = await ref.watch(userRepositoryProvider.future);
  return ValidateUserUseCase(userRepo);
});

final getUserByCredentialsUseCaseProvider = FutureProvider<GetUserByCredentialsUseCase>((ref) async {
  final userRepo = await ref.watch(userRepositoryProvider.future);
  return GetUserByCredentialsUseCase(userRepo);
});

final authPageViewModelProvider = FutureProvider<AuthPageViewModel>((ref) async {
  final serverCompat = await ref.watch(serverVersionCompatibilityUseCase.future);

  final testHost = await ref.watch(testHostConnectionUseCaseProvider.future);
  final login = await ref.watch(loginWithApiKeyUseCaseProvider.future);

  return AuthPageViewModel(serverCompat, testHost, login);
});
