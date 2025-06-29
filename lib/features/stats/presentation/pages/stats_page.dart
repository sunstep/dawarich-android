import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/features/stats/presentation/models/stats_viewmodel.dart';
import 'package:dawarich/features/stats/presentation/models/stats_page_viewmodel.dart';
import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/core/shell/drawer/drawer.dart';
import 'package:dawarich/shared/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // This fires off the initial load so vm.isLoading kicks in right away
      create: (_) => getIt<StatsPageViewModel>()..refreshStats(),
      child: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).pageBackground,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const CustomAppbar(
            title: 'Stats',
            titleFontSize: 32,
            backgroundColor: Colors.transparent,
          ),
          drawer: const CustomDrawer(),
          body: SafeArea(
            child: Consumer<StatsPageViewModel>(
              builder: (ctx, vm, _) {
                // Branch on loading
                return vm.isLoading
                    ? _buildFullSkeleton(ctx)
                    : _buildFullContent(ctx, vm);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOverviewSkeleton(context),
          const SizedBox(height: 32),
          _buildBreakdownSkeletonGrid(context),
        ],
      ),
    );
  }

  Widget _buildOverviewSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade600 : Colors.grey.shade100;

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(width: 150, height: 24, color: baseColor),
            ),
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                width: 120,
                height: 36,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownSkeletonGrid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade600 : Colors.grey.shade100;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: 5,
      itemBuilder: (_, __) => Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(backgroundColor: baseColor, radius: 24),
              const SizedBox(height: 12),
              Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(width: 40, height: 20, color: baseColor),
              ),
              const SizedBox(height: 4),
              Container(width: 60, height: 14, color: baseColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullContent(BuildContext context, StatsPageViewModel vm) {
    return RefreshIndicator(
      onRefresh: vm.refreshStats,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOverviewCard(context, vm),
            const SizedBox(height: 32),
            _buildBreakdownGrid(context, vm),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, StatsPageViewModel vm) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Text(
                'Your Journey',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Stats'),
                style: Theme.of(context).elevatedButtonTheme.style,
                onPressed: vm.isLoading ? null : vm.refreshStats,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownGrid(BuildContext context, StatsPageViewModel vm) {
    final StatsViewModel stats = vm.stats!;
    final List<_StatTile> tiles = [
      _StatTile(
          label: 'Countries',
          value: stats.totalCountries(context),
          icon: Icons.public,
          color: Colors.purple),
      _StatTile(
          label: 'Cities',
          value: stats.totalCities(context),
          icon: Icons.location_city,
          color: Colors.green),
      _StatTile(
          label: 'Points',
          value: stats.totalPoints(context),
          icon: Icons.place,
          color: Colors.pink),
      _StatTile(
          label: 'Geo-coded',
          value: stats.totalReverseGeocodedPoints(context),
          icon: Icons.map,
          color: Colors.orange),
      _StatTile(
          label: 'Distance',
          value: '${stats.totalDistance(context)} km',
          icon: Icons.directions_walk,
          color: Colors.blue),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: tiles.length,
      itemBuilder: (_, i) => tiles[i],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              radius: 24,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            // auto-scale large numbers
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
