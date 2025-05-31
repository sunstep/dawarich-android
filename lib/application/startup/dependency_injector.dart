import 'package:dawarich/application/services/api_config_service.dart';
import 'package:dawarich/application/services/connect_service.dart';
import 'package:dawarich/application/services/location_service.dart';
import 'package:dawarich/application/services/map_service.dart';
import 'package:dawarich/application/services/local_point_service.dart';
import 'package:dawarich/application/services/api_point_service.dart';
import 'package:dawarich/application/services/point_automation_service.dart';
import 'package:dawarich/application/services/stats_service.dart';
import 'package:dawarich/application/services/system_settings_service.dart';
import 'package:dawarich/application/services/track_service.dart';
import 'package:dawarich/application/services/tracker_preferences_service.dart';
import 'package:dawarich/application/services/user_session_service.dart';
import 'package:dawarich/data/repositories/api_config_repository.dart';
import 'package:dawarich/data/repositories/connect_repository.dart';
import 'package:dawarich/data/repositories/hardware_repository.dart';
import 'package:dawarich/data/repositories/local_point_repository.dart';
import 'package:dawarich/data/repositories/api_point_repository.dart';
import 'package:dawarich/data/repositories/stats_repository.dart';
import 'package:dawarich/data/repositories/track_repository.dart';
import 'package:dawarich/data/repositories/tracker_preferences_repository.dart';
import 'package:dawarich/data/repositories/user_session_repository.dart';
import 'package:dawarich/data/repositories/user_storage_repository.dart';
import 'package:dawarich/data/sources/api/v1/overland/batches/batches_client.dart';
import 'package:dawarich/data/sources/api/v1/points/points_client.dart';
import 'package:dawarich/data/sources/api/v1/stats/stats_client.dart';
import 'package:dawarich/data/sources/api/v1/users/users_client.dart';
import 'package:dawarich/data/sources/hardware/battery_data_client.dart';
import 'package:dawarich/data/sources/hardware/device_data_client.dart';
import 'package:dawarich/data/sources/hardware/gps_data_client.dart';
import 'package:dawarich/data/sources/hardware/connectivity_data_client.dart';
import 'package:dawarich/data/sources/local/database/sqlite_client.dart';
import 'package:dawarich/data/sources/local/secure_storage/api_config_client.dart';
import 'package:dawarich/data/sources/local/shared_preferences/tracker_preferences_client.dart';
import 'package:dawarich/data/sources/local/database/user_storage_client.dart';
import 'package:dawarich/data/sources/local/shared_preferences/user_session.dart';
import 'package:dawarich/data_contracts/interfaces/api_config_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/connect_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/local_point_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/api_point_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/stats_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/track_repository.dart';
import 'package:dawarich/data_contracts/interfaces/tracker_preferences_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/user_session_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/user_storage_repository_interfaces.dart';
import 'package:dawarich/ui/models/local/batch_explorer_viewmodel.dart';
import 'package:dawarich/ui/models/local/connect_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/drawer_viewmodel.dart';
import 'package:dawarich/ui/models/local/map_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/points_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/splash_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/stats_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/tracker_page_viewmodel.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

final class DependencyInjector {

  static void injectDependencies() {
    // Sources
    getIt.registerLazySingleton<SQLiteClient>(() => SQLiteClient());
    getIt.registerLazySingleton<UserSessionClient>(() => UserSessionClient());
    getIt.registerLazySingleton<ApiConfigClient>(() => ApiConfigClient());
    getIt.registerLazySingleton<GpsDataClient>(() => GpsDataClient());
    getIt.registerLazySingleton<DeviceDataClient>(() => DeviceDataClient());
    getIt.registerLazySingleton<BatteryDataClient>(() => BatteryDataClient());
    getIt.registerLazySingleton<ConnectivityDataClient>(() => ConnectivityDataClient());
    getIt.registerLazySingleton<PointsClient>(() => PointsClient(getIt<ApiConfigClient>()));
    getIt.registerLazySingleton<BatchesClient>(() => BatchesClient(getIt<ApiConfigClient>()));
    getIt.registerLazySingleton<StatsClient>(() => StatsClient(getIt<ApiConfigClient>()));
    getIt.registerLazySingleton<UsersApiClient>(() => UsersApiClient(getIt<ApiConfigClient>()));
    getIt.registerLazySingleton<UserStorageClient>(() => UserStorageClient());


    getIt.registerLazySingleton<TrackerPreferencesClient>(
        () => TrackerPreferencesClient()
    );


    // Repositories
    getIt.registerLazySingleton<IApiConfigRepository>(() => ApiConfigRepository(getIt<ApiConfigClient>()));
    getIt.registerLazySingleton<IUserSessionRepository>(() => UserSessionRepository(getIt<UserSessionClient>()));
    getIt.registerLazySingleton<IUserStorageRepository>(() => UserStorageRepository(getIt<UserStorageClient>()));
    getIt.registerLazySingleton<IHardwareRepository>(() => HardwareRepository(getIt<GpsDataClient>(), getIt<DeviceDataClient>(), getIt<BatteryDataClient>(), getIt<ConnectivityDataClient>()));
    getIt.registerLazySingleton<IConnectRepository>(() => ConnectRepository(getIt<ApiConfigClient>(), getIt<UsersApiClient>(), getIt<UserStorageClient>(), getIt<UserSessionClient>()));
    getIt.registerLazySingleton<IApiPointRepository>(() => ApiPointRepository(getIt<PointsClient>(), getIt<BatchesClient>()));
    getIt.registerLazySingleton<ILocalPointRepository>(() => LocalPointRepository(getIt<SQLiteClient>()));
    getIt.registerLazySingleton<IStatsRepository>(() => StatsRepository(getIt<StatsClient>()));
    getIt.registerLazySingleton<ITrackRepository>(() => TrackRepository(getIt<SQLiteClient>()));
    getIt.registerLazySingleton<ITrackerPreferencesRepository>(() => TrackerPreferencesRepository());


    // Services
    getIt.registerLazySingleton<UserSessionService>(() => UserSessionService(getIt<IUserSessionRepository>()));
    getIt.registerLazySingleton<SystemSettingsService>(() => SystemSettingsService());
    getIt.registerLazySingleton<ApiConfigService>(() => ApiConfigService(getIt<IApiConfigRepository>()));
    getIt.registerLazySingleton<ConnectService>(() => ConnectService(getIt<IConnectRepository>()));
    getIt.registerLazySingleton<LocationService>(() => LocationService());
    getIt.registerLazySingleton<MapService>(() => MapService(getIt<ApiPointService>()));
    getIt.registerLazySingleton<ApiPointService>(() => ApiPointService(getIt<IApiPointRepository>()));
    getIt.registerLazySingleton<TrackService>(() => TrackService(getIt<ITrackRepository>(), getIt<IUserSessionRepository>()));
    getIt.registerLazySingleton<TrackerPreferencesService>(() => TrackerPreferencesService(getIt<ITrackerPreferencesRepository>(), getIt<IHardwareRepository>(), getIt<IUserSessionRepository>()));
    getIt.registerLazySingleton<LocalPointService>(() => LocalPointService(getIt<ApiPointService>(), getIt<IUserSessionRepository>(), getIt<ILocalPointRepository>(), getIt<TrackerPreferencesService>(), getIt<ITrackRepository>(), getIt<IHardwareRepository>()));
    // getIt.registerLazySingleton<BackgroundTrackingService>(() => BackgroundTrackingService());
    getIt.registerLazySingleton<PointAutomationService>(() => PointAutomationService(getIt<TrackerPreferencesService>(), getIt<IHardwareRepository>(), getIt<LocalPointService>()));
    getIt.registerLazySingleton<StatsService>(() => StatsService(getIt<IStatsRepository>()));


    // ViewModels
    getIt.registerFactory<SplashViewModel>(() => SplashViewModel(getIt<UserSessionService>(), getIt<ApiConfigService>()));
    getIt.registerFactory<ConnectViewModel>(() => ConnectViewModel(getIt<ConnectService>()));

    getIt.registerFactory<MapViewModel>(
      () {
        final MapViewModel viewModel = MapViewModel(getIt<MapService>(), getIt<LocationService>());
        viewModel.initialize();
        return viewModel;
      },
    );

    getIt.registerFactory<StatsPageViewModel>(
      () {
        final StatsPageViewModel viewModel = StatsPageViewModel(getIt<StatsService>());
        viewModel.fetchStats();
        return viewModel;
      }
    );

    getIt.registerFactory<PointsPageViewModel>(
      () {
        final PointsPageViewModel viewModel = PointsPageViewModel();
        return viewModel;
      }
    );

    getIt.registerFactory<TrackerPageViewModel>(
      () {
        final TrackerPageViewModel viewModel = TrackerPageViewModel(getIt<LocalPointService>(), getIt<PointAutomationService>(), getIt<TrackService>(), getIt<TrackerPreferencesService>(), getIt<SystemSettingsService>());
        return viewModel;
      }
    );

    getIt.registerFactory<BatchExplorerViewModel>(
      () {
        final BatchExplorerViewModel viewModel = BatchExplorerViewModel(getIt<LocalPointService>(), getIt<ApiPointService>());
        return viewModel;
      }
    );

    getIt.registerFactory<DrawerViewModel>(() {
      final DrawerViewModel viewModel = DrawerViewModel(getIt<UserSessionService>(), getIt<ApiConfigService>());
      return viewModel;
    });
  }


}