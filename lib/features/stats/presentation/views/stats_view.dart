import 'package:auto_route/annotations.dart';
import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:dawarich/features/stats/presentation/models/stats_uimodel.dart';
import 'package:dawarich/features/stats/presentation/viewmodels/stats_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/core/shell/drawer/drawer.dart';
import 'package:dawarich/shared/widgets/custom_appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class StatsView extends ConsumerWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsViewmodelProvider);

    return statsAsync.when(
      loading: () => _buildLoadingScaffold(context),
      error: (e, _) => _buildErrorScaffold(context, e, ref),
      data: (stats) => _buildDataScaffold(context, stats, ref),
    );
  }

  Widget _buildLoadingScaffold(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppbar(
          title: 'Stats',
          titleFontSize: 32,
          backgroundColor: Colors.transparent,
        ),
        drawer: CustomDrawer(),
        body: SafeArea(child: _buildFullSkeleton(context)),
      ),
    );
  }

  Widget _buildErrorScaffold(BuildContext context, Object error, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppbar(
          title: 'Stats',
          titleFontSize: 32,
          backgroundColor: Colors.transparent,
        ),
        drawer: CustomDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.read(statsViewmodelProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataScaffold(BuildContext context, StatsUiModel? stats, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppbar(
          title: 'Stats',
          titleFontSize: 32,
          backgroundColor: Colors.transparent,
        ),
        drawer: CustomDrawer(),
        body: SafeArea(
          child: stats == null
              ? _buildEmptyState(context, ref)
              : _buildFullContent(context, stats, ref),
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

  Widget _buildFullContent(BuildContext context, StatsUiModel stats, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(statsViewmodelProvider.notifier).refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOverviewCard(context, ref),
            const SizedBox(height: 32),
            _buildBreakdownGrid(context, stats),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, WidgetRef ref) {
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
                onPressed: () => ref.read(statsViewmodelProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(statsViewmodelProvider.notifier).refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.insights_outlined,
                        size: 48, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'No stats available yet',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pull to refresh, or come back after some activity.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.read(statsViewmodelProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownGrid(BuildContext context, StatsUiModel stats) {
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
