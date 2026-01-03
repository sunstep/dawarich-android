import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;
final backgroundGetIt = GetIt.asNewInstance();

// final class DependencyInjection {
//
//   static Future<void> injectDependencies() async {
//     // Sources
//     getIt.registerSingletonAsync<IApiConfigManager>(() async {
//       if (kDebugMode) {
//         debugPrint('[DI - Main] ApiConfigManager.load start');
//       }
//       final cfg = ApiConfigManager();
//       await cfg.load();
//
//       if (kDebugMode) {
//         debugPrint('[DI - Main] ApiConfigManager.load finished');
//       }
//       return cfg;
//     });
//
//     getIt.registerSingletonWithDependencies<IApiConfigLogout>(
//           () => getIt<IApiConfigManager>() as IApiConfigLogout,
//       dependsOn: [IApiConfigManager],
//     );
//
//     getIt.registerLazySingleton<AuthInterceptor>(
//             () => AuthInterceptor(getIt<IApiConfigManager>()));
//
//     getIt.registerLazySingleton<ErrorInterceptor>(() => ErrorInterceptor());
//
//
//     getIt.registerSingletonWithDependencies<DioClient>(
//       () => DioClient([
//         AuthInterceptor(getIt<IApiConfigManager>()),
//         ErrorInterceptor(),
//       ]),
//       dependsOn: [IApiConfigManager],
//     );
//
//     getIt.registerSingletonAsync<SQLiteClient>(() async {
//
//       if (kDebugMode) {
//         debugPrint('[DI - Main] loading SQLiteClient...');
//       }
//       final c = await SQLiteClient.connectSharedIsolate();
//
//       if (kDebugMode) {
//         debugPrint('[DI - Main] SQLiteClient loaded.' );
//       }
//       return c;
//     });
//     getIt.registerLazySingleton<DeviceDataClient>(() => DeviceDataClient());
//     getIt.registerLazySingleton<ConnectivityDataClient>(
//         () => ConnectivityDataClient());
//
//     // Repositories
//     getIt.registerLazySingleton<IVersionRepository>(() => VersionRepository(
//         getIt<DioClient>())
//     );
//     getIt.registerLazySingleton<IUserRepository>(
//         () => DriftUserRepository(getIt<SQLiteClient>()));
//     getIt.registerLazySingleton<IHardwareRepository>(() => HardwareRepository(
//         getIt<DeviceDataClient>(),
//         getIt<ConnectivityDataClient>()));
//     getIt.registerLazySingleton<IConnectRepository>(() => ConnectRepository(
//         getIt<IApiConfigManager>(), getIt<DioClient>()));
//     getIt.registerLazySingleton<IApiPointRepository>(
//         () => ApiPointRepository(getIt<DioClient>()));
//     getIt.registerLazySingleton<IPointLocalRepository>(
//         () => DriftPointLocalRepository(getIt<SQLiteClient>()));
//     getIt.registerLazySingleton<IStatsRepository>(
//         () => StatsRepository(getIt<DioClient>()));
//     getIt.registerLazySingleton<ITrackRepository>(
//         () => DriftTrackRepository(getIt<SQLiteClient>()));
//     getIt.registerLazySingleton<ITrackerSettingsRepository>(
//         () => DriftTrackerSettingsRepository(getIt<SQLiteClient>()));
//
//
//     // Services
//
//
//     getIt.registerSingletonAsync<SessionBox<User>>(() async {
//
//       if (kDebugMode) {
//         debugPrint('[DI - Main] Loading session box...');
//       }
//
//       final di =  await SessionBox.create<User>(
//         encrypt: false,
//         toJson: (user) => user.toJson(),
//         fromJson: (json) => User.fromJson(json),
//         isValidUser: (user) => getIt<ValidateUserUseCase>()(user),
//       );
//
//       if (kDebugMode) {
//         debugPrint('[DI - Main] session box loaded.');
//       }
//
//       return di;
//     });
//
//     getIt.registerLazySingleton<TrackingNotificationService>(() {
//       return TrackingNotificationService();
//     });
//
//     getIt.registerLazySingleton<SystemSettingsService>(
//         () => SystemSettingsService());
//     getIt.registerLazySingleton<ApiConfigService>(
//         () => ApiConfigService(getIt<IApiConfigLogout>()));
//     getIt.registerLazySingleton<LocationService>(() => LocationService());
//     getIt.registerLazySingleton<TimelineService>(
//         () => TimelineService(getIt<IApiPointRepository>()));
//     getIt.registerLazySingleton<ApiPointService>(
//         () => ApiPointService(getIt<IApiPointRepository>()));
//     getIt.registerLazySingleton<TrackerSettingsService>(() =>
//         TrackerSettingsService(getIt<ITrackerSettingsRepository>(),
//             getIt<IHardwareRepository>(), getIt<SessionBox<User>>()));
//     getIt.registerLazySingleton<LocalPointService>(() => LocalPointService(
//         getIt<IApiPointRepository>(),
//         getIt<SessionBox<User>>(),
//         getIt<IPointLocalRepository>(),
//         getIt<TrackerSettingsService>(),
//         getIt<ITrackRepository>(),
//         getIt<IHardwareRepository>()));
//     getIt.registerLazySingleton<StatsService>(
//         () => StatsService(getIt<IStatsRepository>()));
//
//     // ViewModels
//     getIt.registerFactory<AuthPageViewModel>(() =>
//         AuthPageViewModel(getIt<ConnectService>(), getIt<VersionCheckService>()));
//
//     getIt.registerFactory<MigrationViewModel>(() =>
//         MigrationViewModel());
//
//     getIt.registerFactory<VersionCheckViewModel>(() => VersionCheckViewModel(
//         getIt<VersionCheckService>())
//     );
//
//     getIt.registerFactory<TimelineViewModel>(() =>
//         TimelineViewModel(getIt<TimelineService>(), getIt<LocalPointService>()),
//     );
//
//     getIt.registerFactory<StatsPageViewModel>(() =>
//         StatsPageViewModel(getIt<StatsService>())
//     );
//
//     getIt.registerFactory<PointsPageViewModel>(() =>
//       PointsPageViewModel(getIt<ApiPointService>())
//     );
//
//     getIt.registerFactory<TrackerPageViewModel>(() =>
//       TrackerPageViewModel(
//           getIt<LocalPointService>(),
//           getIt<TrackService>(),
//           getIt<TrackerSettingsService>(),
//           getIt<SystemSettingsService>())
//     );
//
//     getIt.registerFactory<BatchExplorerViewModel>(() =>
//       BatchExplorerViewModel(
//           getIt<LocalPointService>())
//     );
//
//     getIt.registerLazySingleton<DrawerViewModel>(() =>
//       DrawerViewModel(
//           getIt<SessionBox<User>>(), getIt<ApiConfigService>())
//     );
//   }
//
//   static Future<void> injectBackgroundDependencies(ServiceInstance instance) async {
//
//     backgroundGetIt.registerSingletonIfAbsent(
//       () => instance,
//       dispose: (final svc) {
//         svc.stopSelf();
//       }
//     );
//
//     final configManager = ApiConfigManager();
//     await configManager.load();
//     backgroundGetIt.registerSingletonIfAbsent<IApiConfigManager>(
//         () => configManager
//     );
//
//     final authIncpterceptor = AuthInterceptor(backgroundGetIt<IApiConfigManager>());
//     final errorInterceptor = ErrorInterceptor();
//
//     backgroundGetIt.registerLazySingletonIfAbsent<AuthInterceptor>(
//             () => authIncpterceptor);
//
//     backgroundGetIt.registerLazySingletonIfAbsent<ErrorInterceptor>(() => errorInterceptor);
//
//
//     backgroundGetIt.registerLazySingletonIfAbsent<DioClient>(
//           () => DioClient([authIncpterceptor, errorInterceptor,
//       ]),
//     );
//
//     backgroundGetIt.registerLazySingletonIfAbsent<DeviceDataClient>(() => DeviceDataClient());
//     backgroundGetIt.registerLazySingletonIfAbsent<ConnectivityDataClient>(() => ConnectivityDataClient());
//
//     backgroundGetIt.registerSingletonAsync<SQLiteClient>(
//           () => SQLiteClient.connectSharedIsolate(),
//     );
//
//     await backgroundGetIt.isReady<SQLiteClient>();
//
//     backgroundGetIt.registerLazySingletonIfAbsent<ITrackerSettingsRepository>(
//             () => DriftTrackerSettingsRepository(backgroundGetIt<SQLiteClient>()));
//     backgroundGetIt.registerLazySingletonIfAbsent<IHardwareRepository>(() => HardwareRepository(
//         backgroundGetIt<DeviceDataClient>(),
//         backgroundGetIt<ConnectivityDataClient>()));
//     backgroundGetIt.registerSingletonWithDependenciesIfAbsent<IUserRepository>(
//           () => DriftUserRepository(backgroundGetIt<SQLiteClient>()),
//       dependsOn: [SQLiteClient],
//     );
//     backgroundGetIt.registerSingletonWithDependenciesIfAbsent<IPointLocalRepository>(
//           () => DriftPointLocalRepository(backgroundGetIt<SQLiteClient>()),
//       dependsOn: [SQLiteClient],
//     );
//
//     backgroundGetIt.registerSingletonWithDependenciesIfAbsent<ITrackRepository>(
//           () => DriftTrackRepository(backgroundGetIt<SQLiteClient>()),
//       dependsOn: [SQLiteClient],
//     );
//
//
//
//     backgroundGetIt.registerSingletonAsync<SessionBox<User>>(() async {
//       SessionBox<User> sessionBox = await SessionBox.create<User>(
//         encrypt: false,
//         toJson: (user) => user.toJson(),
//         fromJson: (json) => User.fromJson(json),
//         isValidUser: (user) => backgroundGetIt<AuthService>().isValidUser(user),
//       );
//
//       return sessionBox;
//     });
//
//     await backgroundGetIt.isReady<SessionBox<User>>();
//
//     backgroundGetIt.registerLazySingletonIfAbsent<IApiPointRepository>(() => ApiPointRepository(
//         backgroundGetIt<DioClient>()));
//     backgroundGetIt.registerLazySingletonIfAbsent<ApiPointService>(() => ApiPointService(
//         backgroundGetIt<IApiPointRepository>()));
//
//     backgroundGetIt.registerSingletonWithDependenciesIfAbsent<TrackerSettingsService>(
//           () => TrackerSettingsService(
//           backgroundGetIt<ITrackerSettingsRepository>(),
//           backgroundGetIt<IHardwareRepository>(),
//           backgroundGetIt<SessionBox<User>>()),
//       dependsOn: [SessionBox<User>],
//     );
//
//     backgroundGetIt.registerSingletonWithDependenciesIfAbsent<LocalPointService>(
//           () => LocalPointService(
//         backgroundGetIt<IApiPointRepository>(),
//         backgroundGetIt<SessionBox<User>>(),
//         backgroundGetIt<IPointLocalRepository>(),
//         backgroundGetIt<TrackerSettingsService>(),
//         backgroundGetIt<ITrackRepository>(),
//         backgroundGetIt<IHardwareRepository>(),
//       ),
//       dependsOn: [
//         SessionBox<User>,
//         IPointLocalRepository,
//         ITrackRepository,
//         TrackerSettingsService,
//       ],
//     );
//
//     backgroundGetIt.registerLazySingletonIfAbsent(() {
//       // Background isolate also defers initialize until first use.
//       return TrackingNotificationService();
//     });
//
//     backgroundGetIt.registerSingletonWithDependenciesIfAbsent<PointAutomationService>(
//         () => PointAutomationService(
//           backgroundGetIt<TrackerSettingsService>(),
//           backgroundGetIt<LocalPointService>(),
//           backgroundGetIt<TrackingNotificationService>()
//         ),
//       dependsOn: [LocalPointService, TrackerSettingsService],
//     );
//
//   }
//
//   static Future<void> disposeBackgroundDependencies() async {
//     try {
//       if (backgroundGetIt.isRegistered<SQLiteClient>()) {
//         await backgroundGetIt<SQLiteClient>().close();
//       }
//
//       await backgroundGetIt.reset(dispose: true);
//       debugPrint("[BG] DI disposed");
//     } catch (e, s) {
//       debugPrint("[BG] DI dispose error: $e\n$s");
//     }
//   }
// }
