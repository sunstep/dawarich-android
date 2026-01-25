import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:dawarich/core/di/providers/drawer_providers.dart';
import 'package:dawarich/core/shell/drawer/drawer_viewmodel.dart';
import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/core/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class CustomDrawer extends ConsumerStatefulWidget {

  const CustomDrawer({super.key});

  @override
  ConsumerState<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    final vmAsync = ref.watch(drawerViewModelProvider);

    return vmAsync.when(
      loading: () => _buildDrawerShell(
        context,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _buildDrawerShell(
        context,
        child: Center(child: Text(e.toString())),
      ),
      data: (vm) => _CustomDrawerContent(
        vm: vm,
        onNavigate: (route) => _navigateTo(context, route),
        onLogout: () => _logout(context, vm),
      ),
    );
  }

  Widget _buildDrawerShell(BuildContext context, {required Widget child}) {
    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.transparent,
        width: MediaQuery.of(context).size.width * 0.75,
        child: ClipRRect(
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  void _closeDrawer(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _runNavGuarded(Future<void> Function() action) {
    if (_isNavigating) {
      return;
    }

    _isNavigating = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await action();
      } finally {
        _isNavigating = false;
      }
    });
  }

  Future<void> _navigateTo(BuildContext context, PageRouteInfo<Object?> route) async {
    final router = context.router.root;
    _runNavGuarded(() async {
      if (!mounted) return;
      _closeDrawer(context);
      await router.replace(route);
    });
  }

  Future<void> _logout(BuildContext context, DrawerViewModel vm) async {
    final router = context.router.root;
    _runNavGuarded(() async {
      if (!mounted) return;
      _closeDrawer(context);
      await vm.logout();

      if (!mounted) {
        return;
      }

      router.replaceAll([const AuthRoute()]);
    });
  }

}

final class _CustomDrawerContent extends StatelessWidget {

  final DrawerViewModel vm;
  final void Function(PageRouteInfo<Object?> route) onNavigate;
  final VoidCallback onLogout;

  const _CustomDrawerContent({
    required this.vm,
    required this.onNavigate,
    required this.onLogout,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = theme.colorScheme.onSurface.withValues(alpha: 0.95);
    final iconColor = theme.colorScheme.onSurface.withValues(alpha: isDark ? 0.7 : 0.65);
    final selectedBg = Colors.red.withValues(alpha: isDark ? 0.3 : 0.1);
    final selectedIcon = theme.colorScheme.secondary;

    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.transparent,
        width: MediaQuery.of(context).size.width * 0.75,
        child: ClipRRect(
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(gradient: theme.pageBackground),
              child: Column(
                children: [
                  Container(
                    height: 120,
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      'Dawarich',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(
                    color: theme.dividerColor.withValues(alpha: 0.5),
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
                          onTap: () => onNavigate(const TimelineRoute()),
                          textColor: textColor,
                          iconColor: iconColor,
                          selectedBg: selectedBg,
                          selectedIconColor: selectedIcon,
                        ),
                        _tile(
                          context,
                          icon: Icons.analytics,
                          label: 'Stats',
                          onTap: () => onNavigate(const StatsRoute()),
                          textColor: textColor,
                          iconColor: iconColor,
                          selectedBg: selectedBg,
                          selectedIconColor: selectedIcon,
                        ),
                        _tile(
                          context,
                          icon: Icons.place,
                          label: 'Points',
                          onTap: () => onNavigate(const PointsRoute()),
                          textColor: textColor,
                          iconColor: iconColor,
                          selectedBg: selectedBg,
                          selectedIconColor: selectedIcon,
                        ),
                        _tile(
                          context,
                          icon: Icons.gps_fixed,
                          label: 'Tracker',
                          onTap: () => onNavigate(const TrackerRoute()),
                          textColor: textColor,
                          iconColor: iconColor,
                          selectedBg: selectedBg,
                          selectedIconColor: selectedIcon,
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                    thickness: 1,
                    height: 1,
                  ),
                  _tile(
                    context,
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: onLogout,
                    textColor: Colors.red.shade300,
                    iconColor: Colors.red.shade200,
                    selectedBg: Colors.red.shade900.withValues(alpha: 0.3),
                    selectedIconColor: Colors.redAccent,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
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
