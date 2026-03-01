import 'package:dawarich/features/version_check/application/repository/version_repository_interfaces.dart';
import 'package:dawarich/features/version_check/application/usecases/get_server_version_usecase.dart';
import 'package:dawarich/features/version_check/application/usecases/refresh_server_compatibility_usecase.dart';
import 'package:dawarich/features/version_check/data/repositories/riverpod_server_compatibility_store.dart';
import 'package:dawarich/features/version_check/data/repositories/version_repository.dart';
import 'package:dawarich/features/version_check/data/sources/compat_rules_remote_data_source.dart';
import 'package:dawarich/features/version_check/data/sources/server_version_remote_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

final compatRulesRemoteDataSourceProvider = FutureProvider<ICompatRulesRemoteDataSource>((ref) async {
  final dio = await ref.watch(dioClientProvider.future);
  return CompatRulesRemoteDataSource(dio);
});

final serverVersionRemoteDataSourceProvider = FutureProvider<IServerVersionRemoteDataSource>((ref) async {
  final dio = await ref.watch(dioClientProvider.future);
  return ServerVersionRemoteDataSource(dio);
});

final versionRepositoryProvider = FutureProvider<IVersionRepository>((ref) async {
  return VersionRepository(
    await ref.watch(serverVersionRemoteDataSourceProvider.future),
    await ref.watch(compatRulesRemoteDataSourceProvider.future),
  );
});

final refreshServerCompatibilityUseCaseProvider = FutureProvider<RefreshServerCompatibilityUseCase>((ref) async {
  final repo = await ref.watch(versionRepositoryProvider.future);
  final store = RiverpodServerCompatibilityStore(ref);
  return RefreshServerCompatibilityUseCase(repo, store);
});

final getServerVersionUseCaseProvider = FutureProvider<GetServerVersionUseCase>((ref) async {
  final repo = await ref.watch(versionRepositoryProvider.future);
  return GetServerVersionUseCase(repo);
});
