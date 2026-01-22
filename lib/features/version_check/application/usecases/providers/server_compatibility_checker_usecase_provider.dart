import 'package:dawarich/core/di/providers/version_check_providers.dart';
import 'package:dawarich/features/version_check/application/repository/version_repository_interfaces.dart';
import 'package:dawarich/features/version_check/application/usecases/server_version_compatibility_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final serverCompatibilityCheckerUsecaseProvider = FutureProvider<ServerVersionCompatibilityUseCase>((ref) async {
  final IVersionRepository versionRepository = await ref.watch(versionRepositoryProvider.future);
  return ServerVersionCompatibilityUseCase(versionRepository);
});
