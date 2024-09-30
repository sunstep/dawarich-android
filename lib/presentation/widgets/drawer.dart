import 'package:flutter/material.dart';
import 'package:dawarich/presentation/routing/app_router.dart';



class CustomDrawer extends StatelessWidget {

  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
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
            leading: const Icon(Icons.download),
            title: const Text("Imports"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed(AppRouter.imports);

            }
          ),
          ListTile(
            leading: const Icon(Icons.publish),
            title: const Text("Exports"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed(AppRouter.exports);

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
      ),
    );
  }

}