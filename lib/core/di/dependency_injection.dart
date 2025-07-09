import 'dart:io';

import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/database/repositories/drift/drift_local_point_repository.dart';
import 'package:dawarich/core/database/repositories/drift/drift_track_repository.dart';
import 'package:dawarich/core/database/repositories/drift/drift_user_repository.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/core/network/interceptors/auth_interceptor.dart';
import 'package:dawarich/core/network/interceptors/error_interceptor.dart';
import 'package:dawarich/core/shell/drawer/api_config_service.dart';
import 'package:dawarich/core/shell/drawer/i_api_config_logout.dart';
import 'package:dawarich/features/auth/application/services/auth_service.dart';
import 'package:dawarich/features/auth/application/services/connect_service.dart';
import 'package:dawarich/features/auth/data_contracts/interfaces/user_repository_interfaces.dart';
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
import 'package:dawarich/features/batch/presentation/models/batch_explorer_viewmodel.dart';
import 'package:dawarich/features/auth/presentation/models/connect_page_viewmodel.dart';
import 'package:dawarich/core/shell/drawer/drawer_viewmodel.dart';
import 'package:dawarich/features/timeline/presentation/models/timeline_page_viewmodel.dart';
import 'package:dawarich/features/migration/presentation/models/migration_viewmodel.dart';
import 'package:dawarich/features/points/presentation/models/points_page_viewmodel.dart';
import 'package:dawarich/features/stats/presentation/models/stats_page_viewmodel.dart';
import 'package:dawarich/features/tracking/presentation/models/tracker_page_viewmodel.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:session_box/session_box.dart';

final GetIt getIt = GetIt.instance;
final backgroundGetIt = GetIt.asNewInstance();

final class DependencyInjection {
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
    getIt.registerSingleton<SQLiteClient>(SQLiteClient());
    getIt.registerLazySingleton<GpsDataClient>(() => GpsDataClient());
    getIt.registerLazySingleton<DeviceDataClient>(() => DeviceDataClient());
    getIt.registerLazySingleton<BatteryDataClient>(() => BatteryDataClient());
    getIt.registerLazySingleton<ConnectivityDataClient>(
        () => ConnectivityDataClient());

    // Repositories
    getIt.registerLazySingleton<IUserRepository>(
        () => DriftUserRepository(getIt<SQLiteClient>()));
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

    AuthService authService;

    getIt.registerLazySingleton(() {
      authService = AuthService(getIt<IUserRepository>());
      return authService;
    });

    getIt.registerSingletonAsync<SessionBox<User>>(() async {
      return await SessionBox.create<User>(
        encrypt: false,
        toJson: (user) => user.toJson(),
        fromJson: (json) => User.fromJson(json),
        isValidUser: (user) => getIt<AuthService>().isValidUser(user),
      );
    });

    getIt.registerLazySingleton<MigrationService>(
        () => MigrationService(getIt<SQLiteClient>()));
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
        () => MapService(getIt<ApiPointService>()));
    getIt.registerLazySingleton<ApiPointService>(
        () => ApiPointService(
            getIt<IApiPointRepository>(),
            getIt<SessionBox<User>>()));
    getIt.registerLazySingleton<TrackService>(() => TrackService(
        getIt<ITrackRepository>(), getIt<SessionBox<User>>()));
    getIt.registerLazySingleton<TrackerPreferencesService>(() =>
        TrackerPreferencesService(getIt<ITrackerPreferencesRepository>(),
            getIt<IHardwareRepository>(), getIt<SessionBox<User>>()));
    getIt.registerLazySingleton<LocalPointService>(() => LocalPointService(
        getIt<IApiPointRepository>(),
        getIt<SessionBox<User>>(),
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
    getIt.registerLazySingleton<ConnectViewModel>(() =>
        ConnectViewModel(getIt<ConnectService>()));

    getIt.registerLazySingleton<MigrationViewModel>(() =>
        MigrationViewModel());

    getIt.registerLazySingleton<TimelineViewModel>(() =>
        TimelineViewModel(getIt<MapService>(), getIt<LocationService>()),
    );

    getIt.registerLazySingleton<StatsPageViewModel>(() =>
        StatsPageViewModel(getIt<StatsService>())
    );

    getIt.registerLazySingleton<PointsPageViewModel>(() =>
      PointsPageViewModel(getIt<ApiPointService>())
    );

    getIt.registerLazySingleton<TrackerPageViewModel>(() =>
      TrackerPageViewModel(
          getIt<LocalPointService>(),
          getIt<PointAutomationService>(),
          getIt<TrackService>(),
          getIt<TrackerPreferencesService>(),
          getIt<SystemSettingsService>())
    );

    getIt.registerLazySingleton<BatchExplorerViewModel>(() =>
      BatchExplorerViewModel(
          getIt<LocalPointService>(), getIt<ApiPointService>())
    );

    getIt.registerLazySingleton<DrawerViewModel>(() =>
      DrawerViewModel(
          getIt<SessionBox<User>>(), getIt<ApiConfigService>())
    );
  }

  static Future<void> injectBackgroundDependencies(ServiceInstance instance) async {

    final configManager = ApiConfigManager();
    await configManager.load();
    backgroundGetIt.registerSingleton<IApiConfigManager>(configManager);

    final authIncpterceptor = AuthInterceptor(backgroundGetIt<IApiConfigManager>());
    final errorInterceptor = ErrorInterceptor();

    backgroundGetIt.registerLazySingleton<AuthInterceptor>(
            () => authIncpterceptor);

    backgroundGetIt.registerLazySingleton<ErrorInterceptor>(() => errorInterceptor);


    backgroundGetIt.registerLazySingleton<DioClient>(
          () => DioClient([authIncpterceptor, errorInterceptor,
      ]),
    );

    backgroundGetIt.registerLazySingleton<GpsDataClient>(() => GpsDataClient());
    backgroundGetIt.registerLazySingleton<DeviceDataClient>(() => DeviceDataClient());
    backgroundGetIt.registerLazySingleton<BatteryDataClient>(() => BatteryDataClient());
    backgroundGetIt.registerLazySingleton<ConnectivityDataClient>(() => ConnectivityDataClient());

    final file = File('${(await getApplicationDocumentsDirectory()).path}/dawarich_db.sqlite');
    final isolate = await DriftIsolate.spawn(() => NativeDatabase(
        file,
        setup: (db) => db.execute('PRAGMA journal_mode = WAL;')
    ));
    final connection = await isolate.connect();
    backgroundGetIt.registerLazySingleton<SQLiteClient>(() => SQLiteClient(connection.executor));

    backgroundGetIt.registerLazySingleton<ITrackerPreferencesRepository>(
            () => TrackerPreferencesRepository());
    backgroundGetIt.registerLazySingleton<IHardwareRepository>(() => HardwareRepository(
        backgroundGetIt<GpsDataClient>(),
        backgroundGetIt<DeviceDataClient>(),
        backgroundGetIt<BatteryDataClient>(),
        backgroundGetIt<ConnectivityDataClient>()));
    backgroundGetIt.registerLazySingleton<IUserRepository>(
            () => DriftUserRepository(backgroundGetIt<SQLiteClient>()));

    // Register a simple tracker preferences service
    AuthService authService;

    backgroundGetIt.registerLazySingleton(() {
      authService = AuthService(backgroundGetIt<IUserRepository>());
      return authService;
    });

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

    backgroundGetIt.registerLazySingleton<IApiPointRepository>(() => ApiPointRepository(
        backgroundGetIt<DioClient>()));
    backgroundGetIt.registerLazySingleton<ApiPointService>(() => ApiPointService(
        backgroundGetIt<IApiPointRepository>(), backgroundGetIt<SessionBox<User>>()));

    backgroundGetIt.registerLazySingleton<TrackerPreferencesService>(() => TrackerPreferencesService(
        backgroundGetIt<ITrackerPreferencesRepository>(),
        backgroundGetIt<IHardwareRepository>(),
        backgroundGetIt<SessionBox<User>>()));

    backgroundGetIt.registerLazySingleton<IPointLocalRepository>(() =>
        DriftPointLocalRepository(backgroundGetIt<SQLiteClient>()));
    backgroundGetIt.registerLazySingleton<ITrackRepository>(() =>
        DriftTrackRepository(backgroundGetIt<SQLiteClient>()));

    backgroundGetIt.registerLazySingleton<LocalPointService>(() => LocalPointService(
        backgroundGetIt<IApiPointRepository>(),
        backgroundGetIt<SessionBox<User>>(),
        backgroundGetIt<IPointLocalRepository>(),
        backgroundGetIt<TrackerPreferencesService>(),
        backgroundGetIt<ITrackRepository>(),
        backgroundGetIt<IHardwareRepository>()));

    backgroundGetIt.registerSingleton<PointAutomationService>(PointAutomationService(
        backgroundGetIt<TrackerPreferencesService>(),
        backgroundGetIt<LocalPointService>(),
        instance)
    );
  }
}
