import "package:dawarich/application/dependency_injection/service_locator.dart";
import "package:dawarich/ui/models/splash_page_viewmodel.dart";
import "package:dawarich/ui/routing/app_router.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class SplashPage extends StatelessWidget {

  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final SplashViewModel viewModel = getIt<SplashViewModel>();
        viewModel.setNavigationMethod((isLoggedIn) {
          Navigator.of(context).pushNamedAndRemoveUntil(isLoggedIn ? AppRouter.map : AppRouter.connect, (route) => false);
        });
        return viewModel;
      },
      child: Consumer<SplashViewModel>(
        builder: (context, viewModel, child) {
          return FutureBuilder(
            future: viewModel.initialize(),
            builder: (context, snapshot) {
              // Loading indicator or just pretend like the app is still starting up? lets just keep it like this for now. As it is not the most important thing to deal with.
              return const SizedBox();
            },
          );
        },
      ),
    );
  }
}
