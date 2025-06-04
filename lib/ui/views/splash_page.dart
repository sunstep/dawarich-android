import "package:dawarich/application/startup/dependency_injector.dart";
import "package:dawarich/ui/models/local/splash_page_viewmodel.dart";
import "package:dawarich/ui/routing/app_router.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

final class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<SplashViewModel>(),
      child: Consumer<SplashViewModel>(
        builder: (context, viewModel, child) {
          return FutureBuilder<bool>(
            future: viewModel.needsMigration(),

            builder: (context, migrationSnapshot) {
              if (migrationSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final bool migrateNeeded = migrationSnapshot.data ?? false;
              if (migrateNeeded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(AppRouter.migration);
                });
                return const SizedBox();
              }

              return FutureBuilder<bool>(
                future: viewModel.checkLoginStatusAsync(),
                builder: (context, loginSnapshot) {
                  // While loginCheck is in progress, show a spinner.
                  if (loginSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // If loginSnapshot has an error or data == false, treat as “not logged in.”
                  final bool isLoggedIn =
                  (loginSnapshot.hasData && loginSnapshot.data == true);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      isLoggedIn ? AppRouter.map : AppRouter.connect,
                          (route) => false,
                    );
                  });

                  return const SizedBox();
                },
              );
            },
          );
        },
      ),
    );
  }
}