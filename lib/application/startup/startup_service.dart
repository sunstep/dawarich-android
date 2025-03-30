import 'package:dawarich/application/startup/dependency_injector.dart';

class StartupService {

  static void initializeApp() {

    DependencyInjector.injectDependencies();
  }

}