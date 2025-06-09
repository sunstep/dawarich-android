import 'dart:ui';
import 'package:dawarich/application/startup/dependency_injector.dart';
import 'package:dawarich/ui/models/local/drawer_viewmodel.dart';
import 'package:dawarich/ui/theme/app_gradients.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/ui/routing/app_router.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<DrawerViewModel>();
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<DrawerViewModel>(
        builder: (ctx, vm, _) => _buildDrawer(ctx),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    // full‐height safe area
    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.transparent,
        width: MediaQuery.of(context).size.width * 0.75,
        child: ClipRRect(
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration:
                  BoxDecoration(gradient: Theme.of(context).pageBackground),
              child: _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final vm = context.read<DrawerViewModel>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = theme.colorScheme.onSurface.withValues(alpha: 0.95);
    final iconColor =
        theme.colorScheme.onSurface.withValues(alpha: isDark ? 0.7 : 0.65);
    final selectedBg = Colors.red.withValues(alpha: isDark ? 0.3 : 0.1);

    final selectedIcon = Theme.of(context).colorScheme.secondary;

    return Column(
      children: [
        // you can replace this with your own logo or user info
        Container(
          height: 120,
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            'Dawarich',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: textColor, fontWeight: FontWeight.bold),
          ),
        ),

        Divider(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          thickness: 1,
          height: 1,
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _tile(
                context,
                icon: Icons.map,
                label: 'Timeline',
                onTap: () {
                  Navigator.of(context).popAndPushNamed(AppRouter.map);
                },
                textColor: textColor,
                iconColor: iconColor,
                selectedBg: selectedBg,
                selectedIconColor: selectedIcon,
              ),
              _tile(
                context,
                icon: Icons.analytics,
                label: 'Stats',
                onTap: () {
                  Navigator.of(context).popAndPushNamed(AppRouter.stats);
                },
                textColor: textColor,
                iconColor: iconColor,
                selectedBg: selectedBg,
                selectedIconColor: selectedIcon,
              ),
              _tile(
                context,
                icon: Icons.place,
                label: 'Points',
                onTap: () {
                  Navigator.of(context).popAndPushNamed(AppRouter.points);
                },
                textColor: textColor,
                iconColor: iconColor,
                selectedBg: selectedBg,
                selectedIconColor: selectedIcon,
              ),
              _tile(
                context,
                icon: Icons.gps_fixed,
                label: 'Tracker',
                onTap: () {
                  Navigator.of(context).popAndPushNamed(AppRouter.tracker);
                },
                textColor: textColor,
                iconColor: iconColor,
                selectedBg: selectedBg,
                selectedIconColor: selectedIcon,
              ),
              // _tile(
              //   context,
              //   icon: Icons.settings,
              //   label: 'Settings',
              //   onTap: () {
              //     Navigator.of(context).popAndPushNamed(AppRouter.settings);
              //   },
              //   textColor: textColor,
              //   iconColor: iconColor,
              //   selectedBg: selectedBg,
              //   selectedIconColor: selectedIcon,
              // ),
            ],
          ),
        ),

        Divider(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          thickness: 1,
          height: 1,
        ),

        _tile(
          context,
          icon: Icons.logout,
          label: 'Logout',
          onTap: () async {
            Navigator.pop(context);
            await vm.logout();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRouter.connect,
                (route) => false,
              );
            });
          },
          textColor: Colors.red.shade300,
          iconColor: Colors.red.shade200,
          selectedBg: Colors.red.shade900.withValues(alpha: 0.3),
          selectedIconColor: Colors.redAccent,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color textColor,
    required Color iconColor,
    required Color selectedBg,
    required Color selectedIconColor,
  }) {
    // bump the content down a touch
    const verticalPadding = 16.0;
    const horizontalPadding = 24.0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      leading: Icon(icon, color: iconColor, size: 28),
      title: Text(label, style: TextStyle(color: textColor, fontSize: 18)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hoverColor: selectedBg,
      selectedTileColor: selectedBg,
      selectedColor: selectedIconColor,
      onTap: onTap,
    );
  }
}
