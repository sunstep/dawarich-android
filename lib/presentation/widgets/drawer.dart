import 'package:flutter/material.dart';
import 'package:dawarich/presentation/pages/points_page.dart';
import '../../presentation/pages/tracker_page.dart';
import 'package:dawarich/presentation/pages/stats_page.dart';
import 'package:dawarich/presentation/pages/map_page.dart';
import 'package:dawarich/presentation/pages/imports_page.dart';
import 'package:dawarich/presentation/pages/exports_page.dart';
import 'package:dawarich/presentation/pages/settings_page.dart';


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
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MapPage())
              );
            }
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text("Stats"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const StatsPage())
              );
            }
          ),
          ListTile(
            leading: const Icon(Icons.place),
            title: const Text("Points"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const PointsPage())
              );
            }
          ),
          ListTile(
            leading: const Icon(Icons.gps_fixed),
            title: const Text("Tracker"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const TrackerPage())
              );
            }
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text("Imports"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const ImportsPage())
              );
            }
          ),
          ListTile(
            leading: const Icon(Icons.publish),
            title: const Text("Exports"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const ExportsPage())
              );
            }
          ),
          ListTile(
              leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SettingsPage())
              );
            }
          ),
        ],
      ),
    );
  }

}