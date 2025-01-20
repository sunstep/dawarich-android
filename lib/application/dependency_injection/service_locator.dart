import 'package:dawarich/application/services/api_config_service.dart';
import 'package:dawarich/application/services/connect_service.dart';
import 'package:dawarich/application/services/location_service.dart';
import 'package:dawarich/application/services/map_service.dart';
import 'package:dawarich/application/services/point_creation_service.dart';
import 'package:dawarich/application/services/point_service.dart';
import 'package:dawarich/application/services/stats_service.dart';
import 'package:dawarich/data/repositories/connect_repository.dart';
import 'package:dawarich/data/repositories/point_creation_repository.dart';
import 'package:dawarich/data/repositories/point_repository.dart';
import 'package:dawarich/data/repositories/stats_repository.dart';
import 'package:dawarich/data/sources/api/v1/overland/batches/batches_client.dart';
import 'package:dawarich/data/sources/api/v1/points/points_client.dart';
import 'package:dawarich/data/sources/api/v1/stats/stats_client.dart';
import 'package:dawarich/data/sources/hardware/battery_data_client.dart';
import 'package:dawarich/data/sources/hardware/device_data_client.dart';
import 'package:dawarich/data/sources/hardware/gps_data_client.dart';
import 'package:dawarich/data/sources/hardware/wifi_data_client.dart';
import 'package:dawarich/data/sources/local/secure_storage/api_config_client.dart';
import 'package:dawarich/data_contracts/interfaces/api_config.dart';
import 'package:dawarich/data_contracts/interfaces/connect_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/point_creation_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/point_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/stats_repository_interfaces.dart';
import 'package:dawarich/ui/models/local/connect_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/map_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/points_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/splash_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/stats_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/tracker_page_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

final GetIt getIt = GetIt.I;

void injectDependencies() {

  // Sources
  getIt.registerLazySingleton<IApiConfigSource>(() => ApiConfigClient());
  getIt.registerLazySingleton<GpsDataClient>(() => GpsDataClient());
  getIt.registerLazySingleton<DeviceDataClient>(() => DeviceDataClient());
  getIt.registerLazySingleton<BatteryDataSource>(() => BatteryDataSource());
  getIt.registerLazySingleton<WiFiDataClient>(() => WiFiDataClient());
  getIt.registerLazySingleton<PointsClient>(() => PointsClient(getIt<IApiConfigSource>()));
  getIt.registerLazySingleton<BatchesClient>(() => BatchesClient(getIt<IApiConfigSource>()));
  getIt.registerLazySingleton<StatsClient>(() => StatsClient(getIt<IApiConfigSource>()));

  // Repositories
  getIt.registerLazySingleton<IConnectRepository>(() => ConnectRepository(getIt<IApiConfigSource>()));
  getIt.registerLazySingleton<IPointInterfaces>(() => PointRepository(getIt<PointsClient>()));
  getIt.registerLazySingleton<IPointCreationInterfaces>(() => PointCreationRepository(getIt<GpsDataClient>(), getIt<DeviceDataClient>(), getIt<BatteryDataSource>(), getIt<WiFiDataClient>(), getIt<BatchesClient>()));
  getIt.registerLazySingleton<IStatsRepository>(() => StatsRepository(getIt<StatsClient>()));


  // Services
  getIt.registerLazySingleton<ApiConfigService>(() => ApiConfigService(getIt<IApiConfigSource>()));
  getIt.registerLazySingleton<ConnectService>(() => ConnectService(getIt<IConnectRepository>(), getIt<IApiConfigSource>()));
  getIt.registerLazySingleton<LocationService>(() => LocationService());
  getIt.registerLazySingleton<MapService>(() => MapService(getIt<PointService>()));
  getIt.registerLazySingleton<PointService>(() => PointService(getIt<IPointInterfaces>()));
  getIt.registerLazySingleton<StatsService>(() => StatsService(getIt<IStatsRepository>()));

  // ViewModels
  getIt.registerFactory<SplashViewModel>(() => SplashViewModel(getIt<ApiConfigService>()));
  getIt.registerFactory<ConnectViewModel>(() => ConnectViewModel(getIt<ApiConfigService>(), getIt<ConnectService>()));

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
      final TrackerPageViewModel viewModel = TrackerPageViewModel(getIt<PointCreationService>());

      return viewModel;
    }
  );
}