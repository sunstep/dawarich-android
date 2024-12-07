import 'package:dawarich/application/services/api_config_service.dart';
import 'package:dawarich/data/sources/local/secure_storage/api_config.dart';
import 'package:dawarich/domain/interfaces/api_config.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.I;

void injectDependencies() {

  getIt.registerLazySingleton<ApiConfigService>(() => ApiConfigService(getIt<IApiConfigSource>()));


  getIt.registerLazySingleton<IApiConfigSource>(() => ApiConfigSource());

}