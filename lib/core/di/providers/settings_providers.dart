import 'package:dawarich/core/di/providers/core_providers.dart';
import 'package:dawarich/features/settings/application/repositories/app_settings_repository_interfaces.dart';
import 'package:dawarich/features/settings/application/usecases/authenticate_biometric_usecase.dart';
import 'package:dawarich/features/settings/application/usecases/check_biometric_availability_usecase.dart';
import 'package:dawarich/features/settings/application/usecases/get_lock_timeout_usecase.dart';
import 'package:dawarich/features/settings/application/usecases/is_biometric_lock_enabled_usecase.dart';
import 'package:dawarich/features/settings/application/usecases/set_biometric_lock_enabled_usecase.dart';
import 'package:dawarich/features/settings/application/usecases/set_lock_timeout_usecase.dart';
import 'package:dawarich/features/settings/data/repositories/app_settings_repository.dart';
import 'package:dawarich/features/settings/data/sources/local/app_settings_local_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Data sources ---

final appSettingsLocalDataSourceProvider =
    FutureProvider<IAppSettingsLocalDataSource>((ref) async {
  final db = await ref.watch(sqliteClientProvider.future);
  return AppSettingsLocalDataSource(db.appSettingsDao);
});

// --- Repositories ---

final appSettingsRepositoryProvider =
    FutureProvider<IAppSettingsRepository>((ref) async {
  final local = await ref.watch(appSettingsLocalDataSourceProvider.future);
  return AppSettingsRepository(local);
});

// --- Use cases ---

final isBiometricLockEnabledUseCaseProvider =
    FutureProvider<IsBiometricLockEnabledUseCase>((ref) async {
  final repo = await ref.watch(appSettingsRepositoryProvider.future);
  return IsBiometricLockEnabledUseCase(repo);
});

final setBiometricLockEnabledUseCaseProvider =
    FutureProvider<SetBiometricLockEnabledUseCase>((ref) async {
  final repo = await ref.watch(appSettingsRepositoryProvider.future);
  return SetBiometricLockEnabledUseCase(repo);
});

final getLockTimeoutUseCaseProvider =
    FutureProvider<GetLockTimeoutUseCase>((ref) async {
  final repo = await ref.watch(appSettingsRepositoryProvider.future);
  return GetLockTimeoutUseCase(repo);
});

final setLockTimeoutUseCaseProvider =
    FutureProvider<SetLockTimeoutUseCase>((ref) async {
  final repo = await ref.watch(appSettingsRepositoryProvider.future);
  return SetLockTimeoutUseCase(repo);
});

final checkBiometricAvailabilityUseCaseProvider =
    Provider<CheckBiometricAvailabilityUseCase>(
        (_) => CheckBiometricAvailabilityUseCase());

final authenticateBiometricUseCaseProvider =
    Provider<AuthenticateBiometricUseCase>(
        (_) => AuthenticateBiometricUseCase());
