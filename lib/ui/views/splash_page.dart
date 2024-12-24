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
      create: (_) => getIt<SplashViewModel>(),
      child: Consumer<SplashViewModel>(
        builder: (context, viewModel, child) {
          return FutureBuilder<bool>(
            future: viewModel.checkLoginStatusAsync(),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                final isLoggedIn = snapshot.data!;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    isLoggedIn ? AppRouter.map : AppRouter.connect,
                        (route) => false,
                  );
                });
              }

              return const SizedBox();
            },
          );
        },
      ),
    );
  }
}
