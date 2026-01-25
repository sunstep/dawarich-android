import 'package:dawarich/features/version_check/application/repository/version_repository_interfaces.dart';
import 'package:dawarich/features/version_check/application/usecases/get_server_version_usecase.dart';
import 'package:dawarich/features/version_check/application/usecases/server_version_compatibility_usecase.dart';
import 'package:dawarich/features/version_check/data/repositories/version_repository.dart';
import 'package:dawarich/features/version_check/presentation/viewmodels/version_check_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

final versionRepositoryProvider = FutureProvider<IVersionRepository>((ref) async {
  final dio = await ref.watch(dioClientProvider.future);
  return VersionRepository(dio);
});

final serverVersionCompatibilityUseCase = FutureProvider<ServerVersionCompatibilityUseCase>((ref) async {
  final repo = await ref.watch(versionRepositoryProvider.future);
  return ServerVersionCompatibilityUseCase(repo);
});

final getServerVersionUseCaseProvider = FutureProvider<GetServerVersionUseCase>((ref) async {
  final repo = await ref.watch(versionRepositoryProvider.future);
  return GetServerVersionUseCase(repo);
});

final versionCheckViewModelProvider = FutureProvider<VersionCheckViewModel>((ref) async {
  final compat = await ref.watch(serverVersionCompatibilityUseCase.future);
  final getVersion = await ref.watch(getServerVersionUseCaseProvider.future);
  return VersionCheckViewModel(compat, getVersion);
});