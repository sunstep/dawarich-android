import 'package:dawarich/application/startup/dependency_injector.dart';

final class StartupService {

  static void initializeApp() {

    DependencyInjector.injectDependencies();
    // BackgroundTrackingService.();
  }

}