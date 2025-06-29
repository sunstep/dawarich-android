import 'package:dawarich/core/network/interceptors/auth_interceptor.dart';
import 'package:dawarich/core/network/interceptors/error_interceptor.dart';
import 'package:dawarich/core/shell/drawer/api_config_service.dart';
import 'package:dawarich/core/shell/drawer/i_api_config_logout.dart';
import 'package:dawarich/features/auth/application/services/connect_service.dart';
import 'package:dawarich/features/timeline/application/services/location_service.dart';
import 'package:dawarich/features/timeline/application/services/timeline_service.dart';
import 'package:dawarich/core/application/services/local_point_service.dart';
import 'package:dawarich/core/application/services/api_point_service.dart';
import 'package:dawarich/features/migration/application/services/migration_service.dart';
import 'package:dawarich/features/tracking/application/services/point_automation_service.dart';
import 'package:dawarich/features/stats/application/services/stats_service.dart';
import 'package:dawarich/features/tracking/application/services/system_settings_service.dart';
import 'package:dawarich/features/tracking/application/services/track_service.dart';
import 'package:dawarich/features/tracking/application/services/tracker_preferences_service.dart';
import 'package:dawarich/core/session/user_session_service.dart';
import 'package:dawarich/core/network/api_config/api_config_manager.dart';
import 'package:dawarich/core/network/dio_client.dart';
import 'package:dawarich/features/auth/data/repositories/connect_repository.dart';
import 'package:dawarich/features/tracking/data/repositories/hardware_repository.dart';
import 'package:dawarich/core/network/repositories/api_point_repository.dart';
import 'package:dawarich/features/stats/data/repositories/stats_repository.dart';
import 'package:dawarich/core/database/%20repositories/objectbox/objectbox_point_local_repository.dart';
import 'package:dawarich/core/database/%20repositories/objectbox/objectbox_track_repository.dart';
import 'package:dawarich/core/database/%20repositories/objectbox/objectbox_user_storage_repository.dart';
import 'package:dawarich/features/tracking/data/repositories/tracker_preferences_repository.dart';
import 'package:dawarich/core/session/user_session_repository.dart';
import 'package:dawarich/features/tracking/data/sources/battery_data_client.dart';
import 'package:dawarich/features/tracking/data/sources/device_data_client.dart';
import 'package:dawarich/features/tracking/data/sources/gps_data_client.dart';
import 'package:dawarich/features/tracking/data/sources/connectivity_data_client.dart';
import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/network/api_config/api_config_manager_interfaces.dart';
import 'package:dawarich/features/auth/data_contracts/interfaces/connect_repository_interfaces.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/core/database/%20repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/stats/data_contracts/interfaces/stats_repository_interfaces.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/i_track_repository.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/tracker_preferences_repository_interfaces.dart';
import 'package:dawarich/core/session/legacy_user_session_repository_interfaces.dart';
import 'package:dawarich/features/auth/data_contracts/interfaces/user_storage_repository_interfaces.dart';
import 'package:dawarich/objectbox.g.dart';
import 'package:dawarich/features/batch/presentation/models/batch_explorer_viewmodel.dart';
import 'package:dawarich/features/auth/presentation/models/connect_page_viewmodel.dart';
import 'package:dawarich/core/shell/drawer/drawer_viewmodel.dart';
import 'package:dawarich/features/timeline/presentation/models/timeline_page_viewmodel.dart';
import 'package:dawarich/features/migration/presentation/models/migration_viewmodel.dart';
import 'package:dawarich/features/points/presentation/models/points_page_viewmodel.dart';
import 'package:dawarich/features/stats/presentation/models/stats_page_viewmodel.dart';
import 'package:dawarich/features/tracking/presentation/models/tracker_page_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:user_session_manager/user_session_manager.dart';

final GetIt getIt = GetIt.instance;

final class DependencyInjection {
  static Future<void> injectDependencies() async {
    // Sources
    getIt.registerSingletonAsync<IApiConfigManager>(() async {
      final cfg = ApiConfigManager();
      await cfg.load();
      return cfg;
    });

    final session = await UserSessionManager.create<int>(
      encrypt: false,
    );
    getIt.registerSingleton<UserSessionManager<int>>(session);

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
    getIt.registerLazySingleton<SQLiteClient>(() => SQLiteClient());
    getIt.registerSingletonAsync<Store>(() async {
      final dir = await getApplicationDocumentsDirectory();
      return openStore(directory: '${dir.path}/objectbox');
    });
    getIt.registerLazySingleton<GpsDataClient>(() => GpsDataClient());
    getIt.registerLazySingleton<DeviceDataClient>(() => DeviceDataClient());
    getIt.registerLazySingleton<BatteryDataClient>(() => BatteryDataClient());
    getIt.registerLazySingleton<ConnectivityDataClient>(
        () => ConnectivityDataClient());

    // Repositories
    getIt.registerLazySingleton<ILegacyUserSessionRepository>(
        () => LegacyUserSessionRepository());
    getIt.registerLazySingleton<IUserStorageRepository>(
        () => ObjectBoxUserStorageRepository(getIt<Store>()));
    getIt.registerLazySingleton<IHardwareRepository>(() => HardwareRepository(
        getIt<GpsDataClient>(),
        getIt<DeviceDataClient>(),
        getIt<BatteryDataClient>(),
        getIt<ConnectivityDataClient>()));
    getIt.registerLazySingleton<IConnectRepository>(() => ConnectRepository(
        getIt<IApiConfigManager>(), getIt<DioClient>()));
    getIt.registerLazySingleton<IApiPointRepository>(
        () => ApiPointRepository(getIt<DioClient>()));
    getIt.registerLazySingleton<IPointLocalRepository>(
        () => ObjectBoxPointLocalRepository(getIt<Store>()));
    getIt.registerLazySingleton<IStatsRepository>(
        () => StatsRepository(getIt<DioClient>()));
    getIt.registerLazySingleton<ITrackRepository>(
        () => ObjectBoxTrackRepository(getIt<Store>()));
    getIt.registerLazySingleton<ITrackerPreferencesRepository>(
        () => TrackerPreferencesRepository());

    // Services
    getIt.registerSingletonWithDependencies<MigrationService>(
        () => MigrationService(getIt<SQLiteClient>(), getIt<Store>()),
        dependsOn: [Store]);
    getIt.registerLazySingleton<LegacyUserSessionService>(
        () => LegacyUserSessionService(getIt<ILegacyUserSessionRepository>()));
    getIt.registerLazySingleton<SystemSettingsService>(
        () => SystemSettingsService());
    getIt.registerLazySingleton<ApiConfigService>(
        () => ApiConfigService(getIt<IApiConfigLogout>()));
    getIt.registerLazySingleton<ConnectService>(() => ConnectService(
        getIt<IConnectRepository>(),
        getIt<IApiConfigManager>(),
        getIt<IUserStorageRepository>(),
        getIt<UserSessionManager<int>>()
    ));
    getIt.registerLazySingleton<LocationService>(() => LocationService());
    getIt.registerLazySingleton<MapService>(
        () => MapService(getIt<ApiPointService>()));
    getIt.registerLazySingleton<ApiPointService>(
        () => ApiPointService(getIt<IApiPointRepository>()));
    getIt.registerLazySingleton<TrackService>(() => TrackService(
        getIt<ITrackRepository>(), getIt<UserSessionManager<int>>()));
    getIt.registerLazySingleton<TrackerPreferencesService>(() =>
        TrackerPreferencesService(getIt<ITrackerPreferencesRepository>(),
            getIt<IHardwareRepository>(), getIt<UserSessionManager<int>>()));
    getIt.registerLazySingleton<LocalPointService>(() => LocalPointService(
        getIt<ApiPointService>(),
        getIt<UserSessionManager<int>>(),
        getIt<IPointLocalRepository>(),
        getIt<TrackerPreferencesService>(),
        getIt<ITrackRepository>(),
        getIt<IHardwareRepository>()));
    // getIt.registerLazySingleton<BackgroundTrackingService>(() => BackgroundTrackingService());
    getIt.registerLazySingleton<PointAutomationService>(() =>
        PointAutomationService(getIt<TrackerPreferencesService>(),
            getIt<IHardwareRepository>(), getIt<LocalPointService>()));
    getIt.registerLazySingleton<StatsService>(
        () => StatsService(getIt<IStatsRepository>()));

    // ViewModels
    getIt.registerFactory<ConnectViewModel>(
        () => ConnectViewModel(getIt<ConnectService>()));

    getIt.registerSingletonWithDependencies<MigrationViewModel>(
        () => MigrationViewModel(getIt<MigrationService>()),
        dependsOn: [MigrationService]);

    getIt.registerFactory<TimelineViewModel>(
      () {
        final TimelineViewModel viewModel =
            TimelineViewModel(getIt<MapService>(), getIt<LocationService>());
        viewModel.initialize();
        return viewModel;
      },
    );

    getIt.registerFactory<StatsPageViewModel>(() {
      final StatsPageViewModel viewModel =
          StatsPageViewModel(getIt<StatsService>());
      viewModel.fetchStats();
      return viewModel;
    });

    getIt.registerFactory<PointsPageViewModel>(() {
      final PointsPageViewModel viewModel = PointsPageViewModel();
      return viewModel;
    });

    getIt.registerFactory<TrackerPageViewModel>(() {
      final TrackerPageViewModel viewModel = TrackerPageViewModel(
          getIt<LocalPointService>(),
          getIt<PointAutomationService>(),
          getIt<TrackService>(),
          getIt<TrackerPreferencesService>(),
          getIt<SystemSettingsService>());
      return viewModel;
    });

    getIt.registerFactory<BatchExplorerViewModel>(() {
      final BatchExplorerViewModel viewModel = BatchExplorerViewModel(
          getIt<LocalPointService>(), getIt<ApiPointService>());
      return viewModel;
    });

    getIt.registerFactory<DrawerViewModel>(() {
      final DrawerViewModel viewModel = DrawerViewModel(
          getIt<UserSessionManager<int>>(), getIt<ApiConfigService>());
      return viewModel;
    });
  }
}
