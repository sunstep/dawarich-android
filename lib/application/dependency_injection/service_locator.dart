import 'package:dawarich/application/services/api_config_service.dart';
import 'package:dawarich/application/services/connect_service.dart';
import 'package:dawarich/application/services/location_service.dart';
import 'package:dawarich/application/services/map_service.dart';
import 'package:dawarich/application/services/local_point_service.dart';
import 'package:dawarich/application/services/api_point_service.dart';
import 'package:dawarich/application/services/stats_service.dart';
import 'package:dawarich/application/services/tracker_preferences_service.dart';
import 'package:dawarich/data/repositories/connect_repository.dart';
import 'package:dawarich/data/repositories/local_point_repository.dart';
import 'package:dawarich/data/repositories/api_point_repository.dart';
import 'package:dawarich/data/repositories/stats_repository.dart';
import 'package:dawarich/data/repositories/tracker_preferences_repository.dart';
import 'package:dawarich/data/sources/api/v1/overland/batches/batches_client.dart';
import 'package:dawarich/data/sources/api/v1/points/points_client.dart';
import 'package:dawarich/data/sources/api/v1/stats/stats_client.dart';
import 'package:dawarich/data/sources/api/v1/users/users_client.dart';
import 'package:dawarich/data/sources/hardware/battery_data_client.dart';
import 'package:dawarich/data/sources/hardware/device_data_client.dart';
import 'package:dawarich/data/sources/hardware/gps_data_client.dart';
import 'package:dawarich/data/sources/hardware/wifi_data_client.dart';
import 'package:dawarich/data/sources/local/secure_storage/api_config_client.dart';
import 'package:dawarich/data/sources/local/shared_preferences/tracker_preferences_client.dart';
import 'package:dawarich/data/sources/local/shared_preferences/user_storage_client.dart';
import 'package:dawarich/data_contracts/interfaces/api_config.dart';
import 'package:dawarich/data_contracts/interfaces/connect_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/local_point_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/api_point_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/stats_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/tracker_preferences_repository_interfaces.dart';
import 'package:dawarich/ui/models/local/connect_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/map_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/points_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/splash_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/stats_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/tracker_page_viewmodel.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> injectDependencies() async {

  // Sources
  getIt.registerLazySingleton<ApiConfigClient>(() => ApiConfigClient());
  getIt.registerLazySingleton<IApiConfigSource>(() => ApiConfigClient());
  getIt.registerLazySingleton<GpsDataClient>(() => GpsDataClient());
  getIt.registerLazySingleton<DeviceDataClient>(() => DeviceDataClient());
  getIt.registerLazySingleton<BatteryDataSource>(() => BatteryDataSource());
  getIt.registerLazySingleton<WiFiDataClient>(() => WiFiDataClient());
  getIt.registerLazySingleton<PointsClient>(() => PointsClient(getIt<ApiConfigClient>()));
  getIt.registerLazySingleton<BatchesClient>(() => BatchesClient(getIt<ApiConfigClient>()));
  getIt.registerLazySingleton<StatsClient>(() => StatsClient(getIt<ApiConfigClient>()));
  getIt.registerLazySingleton<UsersClient>(() => UsersClient(getIt<ApiConfigClient>()));
  getIt.registerLazySingleton<UserStorageClient>(() => UserStorageClient());


  getIt.registerLazySingletonAsync<TrackerPreferencesClient>(
    () async {
      return await TrackerPreferencesClient.initialize(getIt<UserStorageClient>());
  });

  await getIt.isReady<TrackerPreferencesClient>();


  // Repositories
  getIt.registerLazySingleton<IConnectRepository>(() => ConnectRepository(getIt<ApiConfigClient>(), getIt<UsersClient>(), getIt<UserStorageClient>()));
  getIt.registerLazySingleton<IApiPointInterfaces>(() => ApiPointRepository(getIt<PointsClient>()));
  getIt.registerLazySingleton<ILocalPointInterfaces>(() => LocalPointRepository(getIt<GpsDataClient>(), getIt<DeviceDataClient>(), getIt<BatteryDataSource>(), getIt<WiFiDataClient>(), getIt<BatchesClient>(), getIt<UserStorageClient>()));
  getIt.registerLazySingleton<IStatsRepository>(() => StatsRepository(getIt<StatsClient>()));
  getIt.registerLazySingleton<ITrackerPreferencesRepository>(() => TrackerPreferencesRepository(getIt<TrackerPreferencesClient>()));


  // Services
  getIt.registerLazySingleton<ApiConfigService>(() => ApiConfigService(getIt<ApiConfigClient>()));
  getIt.registerLazySingleton<ConnectService>(() => ConnectService(getIt<IConnectRepository>()));
  getIt.registerLazySingleton<LocationService>(() => LocationService());
  getIt.registerLazySingleton<MapService>(() => MapService(getIt<ApiPointService>()));
  getIt.registerLazySingleton<ApiPointService>(() => ApiPointService(getIt<IApiPointInterfaces>()));
  getIt.registerLazySingleton<LocalPointService>(() => LocalPointService(getIt<ILocalPointInterfaces>()));
  getIt.registerLazySingleton<StatsService>(() => StatsService(getIt<IStatsRepository>()));
  getIt.registerLazySingleton<TrackerPreferencesService>(() => TrackerPreferencesService(getIt<ITrackerPreferencesRepository>()));

  // ViewModels
  getIt.registerFactory<SplashViewModel>(() => SplashViewModel(getIt<ApiConfigService>()));
  getIt.registerFactory<ConnectViewModel>(() => ConnectViewModel(getIt<ConnectService>()));

  getIt.registerFactory<MapViewModel>(
    () {
      final MapViewModel viewModel = MapViewModel(getIt<MapService>(), getIt<LocationService>());
      viewModel.initialize();
      return viewModel;
    },
  );

  getIt.registerFactory<PointsPageViewModel>(
    () {
      final PointsPageViewModel viewModel = PointsPageViewModel();
      viewModel.initialize();
      return viewModel;
    }
  );

  getIt.registerFactory<StatsPageViewModel>(
    () {
      final StatsPageViewModel viewModel = StatsPageViewModel(getIt<StatsService>());
      viewModel.fetchStats();
      return viewModel;
    }
  );

  getIt.registerFactory<TrackerPageViewModel>(
    () {
      final TrackerPageViewModel viewModel = TrackerPageViewModel(getIt<LocalPointService>(), getIt<TrackerPreferencesService>());
      viewModel.initialize();
      return viewModel;
    }
  );

  await getIt.allReady();
}