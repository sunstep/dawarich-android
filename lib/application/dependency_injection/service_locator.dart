import 'package:dawarich/application/services/api_config_service.dart';
import 'package:dawarich/application/services/connect_service.dart';
import 'package:dawarich/application/services/location_service.dart';
import 'package:dawarich/application/services/map_service.dart';
import 'package:dawarich/application/services/point_service.dart';
import 'package:dawarich/application/services/stats_service.dart';
import 'package:dawarich/data/repositories/connect_repository.dart';
import 'package:dawarich/data/repositories/point_repository.dart';
import 'package:dawarich/data/repositories/stats_repository.dart';
import 'package:dawarich/data/sources/api/v1/points/point_source.dart';
import 'package:dawarich/data/sources/api/v1/stats/stats_source.dart';
import 'package:dawarich/data/sources/local/secure_storage/api_config.dart';
import 'package:dawarich/domain/interfaces/api_config.dart';
import 'package:dawarich/domain/interfaces/connect_repository.dart';
import 'package:dawarich/domain/interfaces/point_interfaces.dart';
import 'package:dawarich/domain/interfaces/stats_interfaces.dart';
import 'package:dawarich/ui/models/local/connect_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/map_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/points_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/splash_page_viewmodel.dart';
import 'package:dawarich/ui/models/local/stats_page_viewmodel.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.I;

void injectDependencies() {

  // Sources
  getIt.registerLazySingleton<IApiConfigSource>(() => ApiConfigSource());
  getIt.registerLazySingleton<PointSource>(() => PointSource(getIt<IApiConfigSource>()));
  getIt.registerLazySingleton<StatsSource>(() => StatsSource(getIt<IApiConfigSource>()));

  // Repositories
  getIt.registerLazySingleton<IConnectRepository>(() => ConnectRepository(getIt<IApiConfigSource>()));
  getIt.registerLazySingleton<IPointInterfaces>(() => PointRepository(getIt<PointSource>()));
  getIt.registerLazySingleton<IStatsRepository>(() => StatsRepository(getIt<StatsSource>()));


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
      final viewModel = MapViewModel(getIt<MapService>(), getIt<LocationService>());
      viewModel.initialize();
      return viewModel;
    },
  );

  getIt.registerFactory<PointsPageViewModel>(
      () {
        final viewModel = PointsPageViewModel();
        viewModel.initialize();
        return viewModel;
      }
  );

  getIt.registerFactory<StatsPageViewModel>(
      () {
        final viewModel = StatsPageViewModel(getIt<StatsService>());
        viewModel.fetchStats();
        return viewModel;
      }
  );
}