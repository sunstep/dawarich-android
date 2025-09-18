import 'dart:async';

import 'package:get_it/get_it.dart';

extension GetItIdempotent on GetIt {

  void registerLazySingletonIfAbsent<T extends Object>(T Function() factory, {
    String? instanceName,
  }) {
    if (!isRegistered<T>(instanceName: instanceName)) {
      registerLazySingleton<T>(factory, instanceName: instanceName);
    }
  }

  void registerSingletonWithDependenciesIfAbsent<T extends Object>(
      T Function() factoryFunc, {
        String? instanceName,
        Iterable<Type>? dependsOn,
        bool signalsReady = false,
        FutureOr<void> Function(T instance)? dispose,
      }) {
    if (isRegistered<T>(instanceName: instanceName)) {
      return;
    }

    registerSingletonWithDependencies<T>(
      factoryFunc,
      instanceName: instanceName,
      dependsOn: dependsOn,
      signalsReady: signalsReady,
      dispose: dispose,
    );
  }


  void registerSingletonIfAbsent<T extends Object>(
      T instance, {
        String? instanceName,
        bool dispose = true,
      }) {
    if (!isRegistered<T>(instanceName: instanceName)) {
      registerSingleton<T>(instance,
          instanceName: instanceName, dispose: dispose ? (i) {
            if (i is Disposable) {
              i.dispose();
            }
          } : null);
    }
  }

  void registerFactoryIfAbsent<T extends Object>(
      T Function() factory, {
        String? instanceName,
      }) {
    if (!isRegistered<T>(instanceName: instanceName)) {
      registerFactory<T>(factory, instanceName: instanceName);
    }
  }
}

abstract interface class Disposable {
  void dispose();
}
