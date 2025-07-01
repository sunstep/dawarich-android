import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/database/repositories/drift/drift_local_point_repository.dart';
import 'package:dawarich/core/database/repositories/drift/drift_track_repository.dart';
import 'package:dawarich/core/database/repositories/drift/drift_user_storage_repository.dart';
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
import 'package:dawarich/core/network/configs/api_config_manager.dart';
import 'package:dawarich/core/network/dio_client.dart';
import 'package:dawarich/features/auth/data/repositories/connect_repository.dart';
import 'package:dawarich/features/tracking/data/repositories/hardware_repository.dart';
import 'package:dawarich/core/network/repositories/api_point_repository.dart';
import 'package:dawarich/features/stats/data/repositories/stats_repository.dart';
import 'package:dawarich/features/tracking/data/repositories/tracker_preferences_repository.dart';
import 'package:dawarich/features/tracking/data/sources/battery_data_client.dart';
import 'package:dawarich/features/tracking/data/sources/device_data_client.dart';
import 'package:dawarich/features/tracking/data/sources/gps_data_client.dart';
import 'package:dawarich/features/tracking/data/sources/connectivity_data_client.dart';
import 'package:dawarich/core/network/configs/api_config_manager_interfaces.dart';
import 'package:dawarich/features/auth/data_contracts/interfaces/connect_repository_interfaces.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/stats/data_contracts/interfaces/stats_repository_interfaces.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/i_track_repository.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/tracker_preferences_repository_interfaces.dart';
import 'package:dawarich/features/auth/data_contracts/interfaces/user_storage_repository_interfaces.dart';
import 'package:dawarich/features/batch/presentation/models/batch_explorer_viewmodel.dart';
import 'package:dawarich/features/auth/presentation/models/connect_page_viewmodel.dart';
import 'package:dawarich/core/shell/drawer/drawer_viewmodel.dart';
import 'package:dawarich/features/timeline/presentation/models/timeline_page_viewmodel.dart';
import 'package:dawarich/features/migration/presentation/models/migration_viewmodel.dart';
import 'package:dawarich/features/points/presentation/models/points_page_viewmodel.dart';
import 'package:dawarich/features/stats/presentation/models/stats_page_viewmodel.dart';
import 'package:dawarich/features/tracking/presentation/models/tracker_page_viewmodel.dart';
import 'package:get_it/get_it.dart';
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
    getIt.registerLazySingleton<GpsDataClient>(() => GpsDataClient());
    getIt.registerLazySingleton<DeviceDataClient>(() => DeviceDataClient());
    getIt.registerLazySingleton<BatteryDataClient>(() => BatteryDataClient());
    getIt.registerLazySingleton<ConnectivityDataClient>(
        () => ConnectivityDataClient());

    // Repositories
    getIt.registerLazySingleton<IUserStorageRepository>(
        () => DriftUserStorageRepository(getIt<SQLiteClient>()));
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
        () => DriftPointLocalRepository(getIt<SQLiteClient>()));
    getIt.registerLazySingleton<IStatsRepository>(
        () => StatsRepository(getIt<DioClient>()));
    getIt.registerLazySingleton<ITrackRepository>(
        () => DriftTrackRepository(getIt<SQLiteClient>()));
    getIt.registerLazySingleton<ITrackerPreferencesRepository>(
        () => TrackerPreferencesRepository());

    // Services
    getIt.registerLazySingleton<MigrationService>(
        () => MigrationService(getIt<SQLiteClient>()));
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
        PointAutomationService(
            getIt<TrackerPreferencesService>(), getIt<LocalPointService>()));
    getIt.registerLazySingleton<StatsService>(
        () => StatsService(getIt<IStatsRepository>()));

    // ViewModels
    getIt.registerFactory<ConnectViewModel>(
        () => ConnectViewModel(getIt<ConnectService>()));

    getIt.registerLazySingleton<MigrationViewModel>(
        () => MigrationViewModel(getIt<MigrationService>()));

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

  static Future<void> injectBackgroundDependencies() async {
    // First, create a user session
    final session = await UserSessionManager.create<int>(encrypt: false);
    getIt.registerSingleton<UserSessionManager<int>>(session);

    // Register simple services that don't depend on the plugin
    getIt.registerLazySingleton<GpsDataClient>(() => GpsDataClient());
    getIt.registerLazySingleton<DeviceDataClient>(() => DeviceDataClient());
    getIt.registerLazySingleton<BatteryDataClient>(() => BatteryDataClient());
    getIt.registerLazySingleton<ConnectivityDataClient>(() => ConnectivityDataClient());

    // Register background-safe repositories
    getIt.registerLazySingleton<ITrackerPreferencesRepository>(() => TrackerPreferencesRepository());
    getIt.registerLazySingleton<IHardwareRepository>(() => HardwareRepository(
        getIt<GpsDataClient>(),
        getIt<DeviceDataClient>(),
        getIt<BatteryDataClient>(),
        getIt<ConnectivityDataClient>()));

    // Create a background-safe API client that doesn't use the plugin
    getIt.registerLazySingleton<DioClient>(() => DioClient([]));
    getIt.registerLazySingleton<IApiPointRepository>(() => ApiPointRepository(getIt<DioClient>()));
    getIt.registerLazySingleton<ApiPointService>(() => ApiPointService(getIt<IApiPointRepository>()));

    // Register a simple tracker preferences service
    getIt.registerLazySingleton<TrackerPreferencesService>(() => TrackerPreferencesService(
        getIt<ITrackerPreferencesRepository>(),
        getIt<IHardwareRepository>(),
        getIt<UserSessionManager<int>>()));

    // Create a background-specific store instance
    final dir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: '${dir.path}/objectbox_background');
    getIt.registerSingleton<Store>(store);

    // Register repositories that depend on store
    getIt.registerLazySingleton<IPointLocalRepository>(() =>
        ObjectBoxPointLocalRepository(getIt<Store>()));
    getIt.registerLazySingleton<ITrackRepository>(() =>
        ObjectBoxTrackRepository(getIt<Store>()));

    // Create a simplified LocalPointService for background use
    getIt.registerLazySingleton<LocalPointService>(() => LocalPointService(
        getIt<ApiPointService>(),
        getIt<UserSessionManager<int>>(),
        getIt<IPointLocalRepository>(),
        getIt<TrackerPreferencesService>(),
        getIt<ITrackRepository>(),
        getIt<IHardwareRepository>()));

    // Finally register PointAutomationService
    getIt.registerSingleton<PointAutomationService>(PointAutomationService(
        getIt<TrackerPreferencesService>(),
        getIt<LocalPointService>()));
  }
}
