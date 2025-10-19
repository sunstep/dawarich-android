import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/database/repositories/drift/drift_local_point_repository.dart';
import 'package:dawarich/core/database/repositories/drift/drift_track_repository.dart';
import 'package:dawarich/core/database/repositories/drift/drift_user_repository.dart';
import 'package:dawarich/core/di/dependency_injection_guards.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/core/network/interceptors/auth_interceptor.dart';
import 'package:dawarich/core/network/interceptors/error_interceptor.dart';
import 'package:dawarich/core/shell/drawer/api_config_service.dart';
import 'package:dawarich/core/shell/drawer/i_api_config_logout.dart';
import 'package:dawarich/features/auth/application/services/auth_service.dart';
import 'package:dawarich/features/auth/application/services/connect_service.dart';
import 'package:dawarich/features/auth/data_contracts/interfaces/user_repository_interfaces.dart';
import 'package:dawarich/features/auth/presentation/models/auth_page_viewmodel.dart';
import 'package:dawarich/features/timeline/application/services/location_service.dart';
import 'package:dawarich/features/timeline/application/services/timeline_service.dart';
import 'package:dawarich/core/application/services/local_point_service.dart';
import 'package:dawarich/core/application/services/api_point_service.dart';
import 'package:dawarich/features/migration/application/services/migration_service.dart';
import 'package:dawarich/features/tracking/application/services/point_automation/point_automation_service.dart';
import 'package:dawarich/features/stats/application/services/stats_service.dart';
import 'package:dawarich/features/tracking/application/services/system_settings_service.dart';
import 'package:dawarich/features/tracking/application/services/track_service.dart';
import 'package:dawarich/features/tracking/application/services/tracker_settings_service.dart';
import 'package:dawarich/core/network/configs/api_config_manager.dart';
import 'package:dawarich/core/network/dio_client.dart';
import 'package:dawarich/features/auth/data/repositories/connect_repository.dart';
import 'package:dawarich/features/tracking/application/services/tracking_notification_service.dart';
import 'package:dawarich/features/tracking/data/repositories/drift_tracker_settings_repository.dart';
import 'package:dawarich/features/tracking/data/repositories/hardware_repository.dart';
import 'package:dawarich/core/network/repositories/api_point_repository.dart';
import 'package:dawarich/features/stats/data/repositories/stats_repository.dart';
import 'package:dawarich/features/tracking/data/sources/device_data_client.dart';
import 'package:dawarich/features/tracking/data/sources/connectivity_data_client.dart';
import 'package:dawarich/core/network/configs/api_config_manager_interfaces.dart';
import 'package:dawarich/features/auth/data_contracts/interfaces/connect_repository_interfaces.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/stats/data_contracts/interfaces/stats_repository_interfaces.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/i_track_repository.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/tracker_settings_repository.dart';
import 'package:dawarich/features/batch/presentation/models/batch_explorer_viewmodel.dart';
import 'package:dawarich/core/shell/drawer/drawer_viewmodel.dart';
import 'package:dawarich/features/timeline/presentation/models/timeline_page_viewmodel.dart';
import 'package:dawarich/features/migration/presentation/models/migration_viewmodel.dart';
import 'package:dawarich/features/points/presentation/models/points_page_viewmodel.dart';
import 'package:dawarich/features/stats/presentation/models/stats_page_viewmodel.dart';
import 'package:dawarich/features/tracking/presentation/models/tracker_page_viewmodel.dart';
import 'package:dawarich/features/version_check/application/version_check_service.dart';
import 'package:dawarich/features/version_check/data/repositories/version_repository.dart';
import 'package:dawarich/features/version_check/data_contracts/version_repository_interfaces.dart';
import 'package:dawarich/features/version_check/presentation/models/version_check_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get_it/get_it.dart';
import 'package:session_box/session_box.dart';

final GetIt getIt = GetIt.instance;
final backgroundGetIt = GetIt.asNewInstance();

final class DependencyInjection {

  static Future<void> injectDependencies() async {
    // Sources
    getIt.registerSingletonAsync<IApiConfigManager>(() async {
      if (kDebugMode) {
        debugPrint('[DI - Main] ApiConfigManager.load start');
      }
      final cfg = ApiConfigManager();
      await cfg.load();

      if (kDebugMode) {
        debugPrint('[DI - Main] ApiConfigManager.load finished');
      }
      return cfg;
    });

    getIt.registerSingletonWithDependencies<IApiConfigLogout>(
          () => getIt<IApiConfigManager>() as IApiConfigLogout,
      dependsOn: [IApiConfigManager],
    );

    getIt.registerLazySingleton<AuthInterceptor>(
            () => AuthInterceptor(getIt<IApiConfigManager>()));

    getIt.registerLazySingleton<ErrorInterceptor>(() => ErrorInterceptor());


    getIt.registerSingletonWithDependencies<DioClient>(
      () => DioClient([
        AuthInterceptor(getIt<IApiConfigManager>()),
        ErrorInterceptor(),
      ]),
      dependsOn: [IApiConfigManager],
    );

    getIt.registerSingletonAsync<SQLiteClient>(() async {

      if (kDebugMode) {
        debugPrint('[DI - Main] loading SQLiteClient...');
      }
      final c = await SQLiteClient.connectSharedIsolate();

      if (kDebugMode) {
        debugPrint('[DI - Main] SQLiteClient loaded.' );
      }
      return c;
    });
    getIt.registerLazySingleton<DeviceDataClient>(() => DeviceDataClient());
    getIt.registerLazySingleton<ConnectivityDataClient>(
        () => ConnectivityDataClient());

    // Repositories
    getIt.registerLazySingleton<IVersionRepository>(() => VersionRepository(
        getIt<DioClient>())
    );
    getIt.registerLazySingleton<IUserRepository>(
        () => DriftUserRepository(getIt<SQLiteClient>()));
    getIt.registerLazySingleton<IHardwareRepository>(() => HardwareRepository(
        getIt<DeviceDataClient>(),
        getIt<ConnectivityDataClient>()));
    getIt.registerLazySingleton<IConnectRepository>(() => ConnectRepository(
        getIt<IApiConfigManager>(), getIt<DioClient>()));
    getIt.registerLazySingleton<IApiPointRepository>(
        () => ApiPointRepository(getIt<DioClient>()));
    getIt.registerLazySingleton<IPointLocalRepository>(
        () => DriftPointLocalRepository(getIt<SQLiteClient>()));
    getIt.registerLazySingleton<IStatsRepository>(
        () => StatsRepository(getIt<DioClient>()));
    getIt.registerLazySingleton<ITrackRepository>(
        () => DriftTrackRepository(getIt<SQLiteClient>()));
    getIt.registerLazySingleton<ITrackerSettingsRepository>(
        () => DriftTrackerSettingsRepository(getIt<SQLiteClient>()));


    // Services

    AuthService authService;

    getIt.registerLazySingleton(() {
      authService = AuthService(getIt<IUserRepository>());
      return authService;
    });

    getIt.registerSingletonAsync<SessionBox<User>>(() async {

      if (kDebugMode) {
        debugPrint('[DI - Main] Loading session box...');
      }

      final di =  await SessionBox.create<User>(
        encrypt: false,
        toJson: (user) => user.toJson(),
        fromJson: (json) => User.fromJson(json),
        isValidUser: (user) => getIt<AuthService>().isValidUser(user),
      );

      if (kDebugMode) {
        debugPrint('[DI - Main] session box loaded.');
      }

      return di;
    });

    getIt.registerLazySingleton<TrackingNotificationService>(() {
      return TrackingNotificationService();
    });

    getIt.registerLazySingleton<MigrationService>(
        () => MigrationService(getIt<SQLiteClient>()));
    getIt.registerLazySingleton<VersionCheckService>(
        () => VersionCheckService(getIt<IVersionRepository>())
    );
    getIt.registerLazySingleton<SystemSettingsService>(
        () => SystemSettingsService());
    getIt.registerLazySingleton<ApiConfigService>(
        () => ApiConfigService(getIt<IApiConfigLogout>()));
    getIt.registerLazySingleton<ConnectService>(() => ConnectService(
        getIt<IConnectRepository>(),
        getIt<IApiConfigManager>(),
        getIt<IUserRepository>(),
        getIt<SessionBox<User>>()
    ));
    getIt.registerLazySingleton<LocationService>(() => LocationService());
    getIt.registerLazySingleton<MapService>(
        () => MapService(getIt<IApiPointRepository>()));
    getIt.registerLazySingleton<ApiPointService>(
        () => ApiPointService(getIt<IApiPointRepository>()));
    getIt.registerLazySingleton<TrackService>(() => TrackService(
        getIt<ITrackRepository>(), getIt<SessionBox<User>>()));
    getIt.registerLazySingleton<TrackerSettingsService>(() =>
        TrackerSettingsService(getIt<ITrackerSettingsRepository>(),
            getIt<IHardwareRepository>(), getIt<SessionBox<User>>()));
    getIt.registerLazySingleton<LocalPointService>(() => LocalPointService(
        getIt<IApiPointRepository>(),
        getIt<SessionBox<User>>(),
        getIt<IPointLocalRepository>(),
        getIt<TrackerSettingsService>(),
        getIt<ITrackRepository>(),
        getIt<IHardwareRepository>()));
    getIt.registerLazySingleton<StatsService>(
        () => StatsService(getIt<IStatsRepository>()));

    // ViewModels
    getIt.registerFactory<AuthPageViewModel>(() =>
        AuthPageViewModel(getIt<ConnectService>(), getIt<VersionCheckService>()));

    getIt.registerFactory<MigrationViewModel>(() =>
        MigrationViewModel());

    getIt.registerFactory<VersionCheckViewModel>(() => VersionCheckViewModel(
        getIt<VersionCheckService>())
    );

    getIt.registerFactory<TimelineViewModel>(() =>
        TimelineViewModel(getIt<MapService>(), getIt<LocalPointService>()),
    );

    getIt.registerFactory<StatsPageViewModel>(() =>
        StatsPageViewModel(getIt<StatsService>())
    );

    getIt.registerFactory<PointsPageViewModel>(() =>
      PointsPageViewModel(getIt<ApiPointService>())
    );

    getIt.registerFactory<TrackerPageViewModel>(() =>
      TrackerPageViewModel(
          getIt<LocalPointService>(),
          getIt<TrackService>(),
          getIt<TrackerSettingsService>(),
          getIt<SystemSettingsService>())
    );

    getIt.registerFactory<BatchExplorerViewModel>(() =>
      BatchExplorerViewModel(
          getIt<LocalPointService>())
    );

    getIt.registerLazySingleton<DrawerViewModel>(() =>
      DrawerViewModel(
          getIt<SessionBox<User>>(), getIt<ApiConfigService>())
    );
  }

  static Future<void> injectBackgroundDependencies(ServiceInstance instance) async {

    backgroundGetIt.registerSingletonIfAbsent(
      () => instance,
      dispose: (final svc) {
        svc.stopSelf();
      }
    );

    final configManager = ApiConfigManager();
    await configManager.load();
    backgroundGetIt.registerSingletonIfAbsent<IApiConfigManager>(
        () => configManager
    );

    final authIncpterceptor = AuthInterceptor(backgroundGetIt<IApiConfigManager>());
    final errorInterceptor = ErrorInterceptor();

    backgroundGetIt.registerLazySingletonIfAbsent<AuthInterceptor>(
            () => authIncpterceptor);

    backgroundGetIt.registerLazySingletonIfAbsent<ErrorInterceptor>(() => errorInterceptor);


    backgroundGetIt.registerLazySingletonIfAbsent<DioClient>(
          () => DioClient([authIncpterceptor, errorInterceptor,
      ]),
    );

    backgroundGetIt.registerLazySingletonIfAbsent<DeviceDataClient>(() => DeviceDataClient());
    backgroundGetIt.registerLazySingletonIfAbsent<ConnectivityDataClient>(() => ConnectivityDataClient());

    backgroundGetIt.registerSingletonAsync<SQLiteClient>(
          () => SQLiteClient.connectSharedIsolate(),
    );

    await backgroundGetIt.isReady<SQLiteClient>();

    backgroundGetIt.registerLazySingletonIfAbsent<ITrackerSettingsRepository>(
            () => DriftTrackerSettingsRepository(backgroundGetIt<SQLiteClient>()));
    backgroundGetIt.registerLazySingletonIfAbsent<IHardwareRepository>(() => HardwareRepository(
        backgroundGetIt<DeviceDataClient>(),
        backgroundGetIt<ConnectivityDataClient>()));
    backgroundGetIt.registerSingletonWithDependenciesIfAbsent<IUserRepository>(
          () => DriftUserRepository(backgroundGetIt<SQLiteClient>()),
      dependsOn: [SQLiteClient],
    );
    backgroundGetIt.registerSingletonWithDependenciesIfAbsent<IPointLocalRepository>(
          () => DriftPointLocalRepository(backgroundGetIt<SQLiteClient>()),
      dependsOn: [SQLiteClient],
    );

    backgroundGetIt.registerSingletonWithDependenciesIfAbsent<ITrackRepository>(
          () => DriftTrackRepository(backgroundGetIt<SQLiteClient>()),
      dependsOn: [SQLiteClient],
    );


    backgroundGetIt.registerSingletonWithDependenciesIfAbsent<AuthService>(
          () => AuthService(backgroundGetIt<IUserRepository>()),
      dependsOn: [IUserRepository],
    );

    backgroundGetIt.registerSingletonAsync<SessionBox<User>>(() async {
      SessionBox<User> sessionBox = await SessionBox.create<User>(
        encrypt: false,
        toJson: (user) => user.toJson(),
        fromJson: (json) => User.fromJson(json),
        isValidUser: (user) => backgroundGetIt<AuthService>().isValidUser(user),
      );

      return sessionBox;
    });

    await backgroundGetIt.isReady<SessionBox<User>>();

    backgroundGetIt.registerLazySingletonIfAbsent<IApiPointRepository>(() => ApiPointRepository(
        backgroundGetIt<DioClient>()));
    backgroundGetIt.registerLazySingletonIfAbsent<ApiPointService>(() => ApiPointService(
        backgroundGetIt<IApiPointRepository>()));

    backgroundGetIt.registerSingletonWithDependenciesIfAbsent<TrackerSettingsService>(
          () => TrackerSettingsService(
          backgroundGetIt<ITrackerSettingsRepository>(),
          backgroundGetIt<IHardwareRepository>(),
          backgroundGetIt<SessionBox<User>>()),
      dependsOn: [SessionBox<User>],
    );

    backgroundGetIt.registerSingletonWithDependenciesIfAbsent<LocalPointService>(
          () => LocalPointService(
        backgroundGetIt<IApiPointRepository>(),
        backgroundGetIt<SessionBox<User>>(),
        backgroundGetIt<IPointLocalRepository>(),
        backgroundGetIt<TrackerSettingsService>(),
        backgroundGetIt<ITrackRepository>(),
        backgroundGetIt<IHardwareRepository>(),
      ),
      dependsOn: [
        SessionBox<User>,
        IPointLocalRepository,
        ITrackRepository,
        TrackerSettingsService,
      ],
    );

    backgroundGetIt.registerLazySingletonIfAbsent(() {
      // Background isolate also defers initialize until first use.
      return TrackingNotificationService();
    });

    backgroundGetIt.registerSingletonWithDependenciesIfAbsent<PointAutomationService>(
        () => PointAutomationService(
          backgroundGetIt<TrackerSettingsService>(),
          backgroundGetIt<LocalPointService>(),
          backgroundGetIt<TrackingNotificationService>()
        ),
      dependsOn: [LocalPointService, TrackerSettingsService],
    );

  }

  static Future<void> disposeBackgroundDependencies() async {
    try {
      if (backgroundGetIt.isRegistered<SQLiteClient>()) {
        await backgroundGetIt<SQLiteClient>().close();
      }

      await backgroundGetIt.reset(dispose: true);
      debugPrint("[BG] DI disposed");
    } catch (e, s) {
      debugPrint("[BG] DI dispose error: $e\n$s");
    }
  }
}
