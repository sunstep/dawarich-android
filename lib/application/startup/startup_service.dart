import 'package:dawarich/application/startup/dependency_injector.dart';

final class StartupService {

  static Future<void> initializeApp() async {

    await DependencyInjector.injectDependencies();
    // BackgroundTrackingService.();
  }

}