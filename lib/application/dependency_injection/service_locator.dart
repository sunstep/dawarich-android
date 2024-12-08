import 'dart:typed_data';

import 'package:dawarich/application/services/api_config_service.dart';
import 'package:dawarich/application/services/location_service.dart';
import 'package:dawarich/application/services/map_service.dart';
import 'package:dawarich/application/services/point_service.dart';
import 'package:dawarich/data/repositories/point_repository.dart';
import 'package:dawarich/data/sources/api/points/point_source.dart';
import 'package:dawarich/data/sources/local/secure_storage/api_config.dart';
import 'package:dawarich/domain/interfaces/api_config.dart';
import 'package:dawarich/domain/interfaces/point_interfaces.dart';
import 'package:dawarich/ui/models/connect_page_viewmodel.dart';
import 'package:dawarich/ui/models/map_page_viewmodel.dart';
import 'package:dawarich/ui/models/points_page_viewmodel.dart';
import 'package:dawarich/ui/models/splash_page_viewmodel.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.I;

void injectDependencies() {
  // Register Sources
  getIt.registerLazySingleton<IApiConfigSource>(() => ApiConfigSource());
  getIt.registerLazySingleton<PointSource>(
        () => PointSource(getIt<IApiConfigSource>()),
  );

  // Register Repositories
  getIt.registerLazySingleton<IPointInterfaces>(
        () => PointRepository(getIt<PointSource>()),
  );

  // Register Services
  getIt.registerLazySingleton<ApiConfigService>(
        () => ApiConfigService(getIt<IApiConfigSource>()),
  );
  getIt.registerLazySingleton<LocationService>(
        () => LocationService(),
  );
  getIt.registerLazySingleton<MapService>(
        () => MapService(getIt<PointService>()),
  );
  getIt.registerLazySingleton<PointService>(
        () => PointService(getIt<IPointInterfaces>()),
  );

  // Register ViewModels
  getIt.registerFactory<SplashViewModel>(
        () => SplashViewModel(getIt<ApiConfigService>()),
  );

  getIt.registerFactory<ConnectViewModel>(
        () => ConnectViewModel(getIt<ApiConfigService>()),
  );

  getIt.registerFactory<MapViewModel>(
        () {
      final viewModel = MapViewModel(getIt<MapService>(), getIt<LocationService>());
      viewModel.initialize(); // Initialize it when created.
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
}


void teardownDependencies() {
  getIt.reset(); // Optional: Clean up when needed
}

