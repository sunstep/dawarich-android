import 'package:dawarich/application/services/api_config_service.dart';
import 'package:dawarich/application/startup/dependency_injector.dart';
import 'package:dawarich/ui/models/local/drawer_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/ui/routing/app_router.dart';
import 'package:provider/provider.dart';


class CustomDrawer extends StatelessWidget {

  const CustomDrawer({super.key});

  Widget _drawerContent(BuildContext context){
    final DrawerViewModel viewModel = context.read<DrawerViewModel>();
    return Column(
      children: [
        Expanded(child:
          ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text("Timeline"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacementNamed(AppRouter.map);
                }
              ),
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text("Stats"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacementNamed(AppRouter.stats);
                }
              ),
              ListTile(
                leading: const Icon(Icons.place),
                title: const Text("Points"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacementNamed(AppRouter.points);
                }
              ),
              ListTile(
                leading: const Icon(Icons.gps_fixed),
                title: const Text("Tracker"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacementNamed(AppRouter.tracker);
                }
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacementNamed(AppRouter.settings);
                }
              ),
            ],
          )
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            "Logout",
            style: TextStyle(color: Colors.red),
          ),
          onTap: () async {
            Navigator.pop(context);
            await viewModel.logout();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.connect, (route) => false);
            });
          },
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrawerViewModel(getIt<ApiConfigService>()),
      child: Builder(
        builder: (context) => Drawer(
          child: _drawerContent(context),
        ),
      ),
    );
  }

}