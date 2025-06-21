import 'package:dawarich/application/services/api_config_service.dart';
import 'package:dawarich/application/services/connect_service.dart';
import 'package:dawarich/application/services/location_service.dart';
import 'package:dawarich/application/services/map_service.dart';
import 'package:dawarich/application/services/local_point_service.dart';
import 'package:dawarich/application/services/api_point_service.dart';
import 'package:dawarich/application/services/migration_service.dart';
import 'package:dawarich/application/services/point_automation_service.dart';
import 'package:dawarich/application/services/stats_service.dart';
import 'package:dawarich/application/services/system_settings_service.dart';
import 'package:dawarich/application/services/track_service.dart';
import 'package:dawarich/application/services/tracker_preferences_service.dart';
import 'package:dawarich/application/services/user_session_service.dart';
import 'package:dawarich/data/dawarich_api/config/api_config_manager.dart';
import 'package:dawarich/data/dawarich_api/sources/api_client.dart';
import 'package:dawarich/data/dawarich_api/repositories/connect_repository.dart';
import 'package:dawarich/data/hardware/repositories/hardware_repository.dart';
import 'package:dawarich/data/drift/repositories/local_point_repository.dart';
import 'package:dawarich/data/dawarich_api/repositories/api_point_repository.dart';
import 'package:dawarich/data/dawarich_api/repositories/stats_repository.dart';
import 'package:dawarich/data/drift/repositories/track_repository.dart';
import 'package:dawarich/data/shared_preferences/tracker_preferences_repository.dart';
import 'package:dawarich/data/shared_preferences/repositories/user_session_repository.dart';
import 'package:dawarich/data/drift/repositories/user_storage_repository.dart';
import 'package:dawarich/data/sources/hardware/battery_data_client.dart';
import 'package:dawarich/data/sources/hardware/device_data_client.dart';
import 'package:dawarich/data/sources/hardware/gps_data_client.dart';
import 'package:dawarich/data/sources/hardware/connectivity_data_client.dart';
import 'package:dawarich/data/drift/database/sqlite_client.dart';
import 'package:dawarich/data_contracts/interfaces/api_config_manager_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/connect_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/local_point_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/api_point_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/stats_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/track_repository.dart';
import 'package:dawarich/data_contracts/interfaces/tracker_preferences_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/user_session_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/user_storage_repository_interfaces.dart';
import 'package:dawarich/objectbox.g.dart';
import 'package:dawarich/ui/models/local/batch_explorer_viewmodel.dart';
import 'package:dawarich/ui/models/local/connect_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/drawer_viewmodel.dart';
import 'package:dawarich/ui/models/local/map_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/migration_viewmodel.dart';
import 'package:dawarich/ui/models/local/points_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/stats_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/tracker_page_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

final GetIt getIt = GetIt.instance;

final class DependencyInjector {
  static Future<void> injectDependencies() async {
    // Sources
    getIt.registerSingletonAsync<IApiConfigManager>(() async {
      final cfg = ApiConfigManager();
      await cfg.load();
      return cfg;
    });
    getIt.registerSingletonWithDependencies<IApiConfigLogout>(
          () => getIt<IApiConfigManager>() as IApiConfigLogout,
      dependsOn: [IApiConfigManager],
    );

    getIt.registerSingletonWithDependencies<ApiClient>(
      () => ApiClient(getIt<IApiConfigManager>()),
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
    getIt.registerLazySingleton<IUserSessionRepository>(
        () => UserSessionRepository());
    getIt.registerLazySingleton<IUserStorageRepository>(
        () => UserStorageRepository(getIt<SQLiteClient>()));
    getIt.registerLazySingleton<IHardwareRepository>(() => HardwareRepository(
        getIt<GpsDataClient>(),
        getIt<DeviceDataClient>(),
        getIt<BatteryDataClient>(),
        getIt<ConnectivityDataClient>()));
    getIt.registerLazySingleton<IConnectRepository>(() => ConnectRepository(
        getIt<IApiConfigManager>(), getIt<ApiClient>()));
    getIt.registerLazySingleton<IApiPointRepository>(
        () => ApiPointRepository(getIt<ApiClient>()));
    getIt.registerLazySingleton<ILocalPointRepository>(
        () => LocalPointRepository(getIt<SQLiteClient>()));
    getIt.registerLazySingleton<IStatsRepository>(
        () => StatsRepository(getIt<ApiClient>()));
    getIt.registerLazySingleton<ITrackRepository>(
        () => TrackRepository(getIt<SQLiteClient>()));
    getIt.registerLazySingleton<ITrackerPreferencesRepository>(
        () => TrackerPreferencesRepository());

    // Services
    getIt.registerSingletonWithDependencies<MigrationService>(
        () => MigrationService(getIt<SQLiteClient>(), getIt<Store>()),
        dependsOn: [Store]);
    getIt.registerLazySingleton<UserSessionService>(
        () => UserSessionService(getIt<IUserSessionRepository>()));
    getIt.registerLazySingleton<SystemSettingsService>(
        () => SystemSettingsService());
    getIt.registerLazySingleton<ApiConfigService>(
        () => ApiConfigService(getIt<IApiConfigLogout>()));
    getIt.registerLazySingleton<ConnectService>(() => ConnectService(
        getIt<IConnectRepository>(),
        getIt<IApiConfigManager>(),
        getIt<IUserStorageRepository>(),
        getIt<IUserSessionRepository>()));
    getIt.registerLazySingleton<LocationService>(() => LocationService());
    getIt.registerLazySingleton<MapService>(
        () => MapService(getIt<ApiPointService>()));
    getIt.registerLazySingleton<ApiPointService>(
        () => ApiPointService(getIt<IApiPointRepository>()));
    getIt.registerLazySingleton<TrackService>(() => TrackService(
        getIt<ITrackRepository>(), getIt<IUserSessionRepository>()));
    getIt.registerLazySingleton<TrackerPreferencesService>(() =>
        TrackerPreferencesService(getIt<ITrackerPreferencesRepository>(),
            getIt<IHardwareRepository>(), getIt<IUserSessionRepository>()));
    getIt.registerLazySingleton<LocalPointService>(() => LocalPointService(
        getIt<ApiPointService>(),
        getIt<IUserSessionRepository>(),
        getIt<ILocalPointRepository>(),
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

    getIt.registerFactory<MapViewModel>(
      () {
        final MapViewModel viewModel =
            MapViewModel(getIt<MapService>(), getIt<LocationService>());
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
          getIt<UserSessionService>(), getIt<ApiConfigService>());
      return viewModel;
    });
  }
}
