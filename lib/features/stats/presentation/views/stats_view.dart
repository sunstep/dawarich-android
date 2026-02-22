import 'package:auto_route/annotations.dart';
import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/core/feature_flags/feature_flags.dart';
import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:dawarich/features/stats/presentation/helpers/stats_period_snapshot.dart';
import 'package:dawarich/features/stats/presentation/models/countries/visited_countries_uimodel.dart';
import 'package:dawarich/features/stats/presentation/models/stats/monthly_stats_uimodel.dart';
import 'package:dawarich/features/stats/presentation/models/stats/stats_uimodel.dart';
import 'package:dawarich/features/stats/presentation/providers/derived/all_time_monthly_distance_provider.dart';
import 'package:dawarich/features/stats/presentation/providers/stats_period_breakdown_provider.dart';
import 'package:dawarich/features/stats/presentation/providers/stats_period_provider.dart';
import 'package:dawarich/features/stats/presentation/sheets/distance_breakdown_sheet.dart';
import 'package:dawarich/features/stats/presentation/viewmodels/stats_page_state.dart';
import 'package:dawarich/features/stats/presentation/viewmodels/stats_viewmodel.dart';
import 'package:dawarich/features/stats/presentation/widgets/period_row.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/core/shell/drawer/drawer.dart';
import 'package:dawarich/shared/widgets/custom_appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:option_result/option_result.dart';
import 'package:shimmer/shimmer.dart';

import '../viewmodels/countries_viewmodel.dart';

@RoutePage()
class StatsView extends ConsumerWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final statsAsync = ref.watch(statsViewmodelProvider);

    final state = statsAsync.value;

    if (statsAsync.hasError && state == null) {
      return _buildErrorScaffold(context, statsAsync.error!, ref);
    }

    if (state == null) {
      return _buildLoadingScaffold(context);
    }

    final flags = ref.watch(featureFlagsProvider);

    final AsyncValue<Result<VisitedCountriesUiModel?, Failure>> countriesAsync =
    flags.visitedPlacesStatsEnabled
        ? ref.watch(countriesViewmodelProvider)
        : const AsyncData<Result<VisitedCountriesUiModel?, Failure>>(Ok(null));

    return _buildDataScaffold(
      context,
      state,
      ref,
      countriesAsync,
      isRefreshing: statsAsync.isLoading,
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

  Widget _buildDataScaffold(
      BuildContext context,
      StatsPageState state,
      WidgetRef ref,
      AsyncValue<Result<VisitedCountriesUiModel?, Failure>> countriesAsync, {
        required bool isRefreshing,
      }) {
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
          child: state.stats == null
              ? _buildEmptyState(context, ref)
              : _buildFullContent(
            context,
            state.stats!,
            ref,
            countriesAsync,
            syncedAtUtc: state.syncedAtUtc,
            isRefreshing: isRefreshing,
          ),
        ),
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

  Future<void> _refreshAll(WidgetRef ref) async {
    final flags = ref.read(featureFlagsProvider);

    final futures = <Future<void>>[
      ref.read(statsViewmodelProvider.notifier).refresh(),
    ];

    if (flags.visitedPlacesStatsEnabled) {
      futures.add(ref.read(countriesViewmodelProvider.notifier).refresh());
    }

    await Future.wait(futures);
  }

  Widget _buildFullContent(
      BuildContext context,
      StatsUiModel stats,
      WidgetRef ref,
      AsyncValue<Result<VisitedCountriesUiModel?, Failure>> countriesAsync, {
        required DateTime? syncedAtUtc,
        required bool isRefreshing,
      }) {
    final selectedYear = ref.watch(selectedStatsYearProvider);
    final years = availableYears(stats);
    final snapshot = resolveStatsForYear(stats: stats, selectedYear: selectedYear);

    final allTimeMonthly = ref.watch(allTimeMonthlyDistanceProvider);

    return RefreshIndicator(
      onRefresh: () async => await _refreshAll(ref),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOverviewCard(
              context,
              ref,
              availableYears: years,
              selectedYear: selectedYear,
              syncedAtUtc: syncedAtUtc,
              isRefreshing: isRefreshing,
            ),

            const SizedBox(height: 24),

            _buildBreakdownGrid(
              context,
              stats,
              ref,
              snapshot: snapshot,
              allTimeMonthly: allTimeMonthly,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
      BuildContext context,
      WidgetRef ref, {
        required List<int> availableYears,
        required int? selectedYear,
        required DateTime? syncedAtUtc,
        required bool isRefreshing,
      }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final lastSyncText = _formatLastSync(context, syncedAtUtc);

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Your Journey',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Last sync row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sync,
                  size: 16,
                  color: cs.onSurface.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 6),
                Text(
                  lastSyncText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isRefreshing) ...[
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            PeriodRow(
              availableYears: availableYears,
              selectedYear: selectedYear,
              onChanged: (v) {
                ref.read(selectedStatsYearProvider.notifier).setYear(v);
              },
            ),

            const SizedBox(height: 16),

            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Stats'),
                style: theme.elevatedButtonTheme.style,
                onPressed: () async => await _refreshAll(ref),
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
                      onPressed: () => _refreshAll(ref),
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

  Widget _buildBreakdownGrid(
      BuildContext context,
      StatsUiModel stats,
      WidgetRef ref, {
        required StatsPeriodSnapshot snapshot,
        required MonthlyStatsUiModel? allTimeMonthly,
      }) {
    final flags = ref.watch(featureFlagsProvider);
    final bool canShowCountries = flags.visitedPlacesStatsEnabled;

    final locale = Localizations.localeOf(context).toString();
    final nf = NumberFormat.decimalPattern(locale);

    final String countriesValue = nf.format(snapshot.totalCountries);
    final String citiesValue = nf.format(snapshot.totalCities);
    final String distanceValue = nf.format(snapshot.totalDistance);

    snapshot.isYearMode ? snapshot.monthlyDistance : allTimeMonthly;

    final List<_StatTile> tiles = [
      _StatTile(
        label: 'Countries',
        value: countriesValue,
        icon: Icons.public,
        color: Colors.purple,
        onTap: canShowCountries ? () => _openCountriesSheet(context, ref) : null,
      ),
      _StatTile(
        label: 'Cities',
        value: citiesValue,
        icon: Icons.location_city,
        color: Colors.green,
        onTap: canShowCountries ? () => _openCitiesSheet(context, ref) : null,
      ),
      _StatTile(
        label: 'Points',
        value: stats.totalPoints(context),
        icon: Icons.place,
        color: Colors.pink,
      ),
      _StatTile(
        label: 'Geo-coded',
        value: stats.totalReverseGeocodedPoints(context),
        icon: Icons.map,
        color: Colors.orange,
      ),
      _StatTile(
        label: 'Distance',
        value: '$distanceValue km',
        icon: Icons.directions_walk,
        color: Colors.blue,
        onTap: () {
          final pageYear = ref.read(selectedStatsYearProvider);
          ref.read(statsBreakdownYearProvider.notifier).syncToPage(pageYear);

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const DistanceBreakdownSheet(),
          );
        },
      ),
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

  void _openCitiesSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatsDetailsSheet(
        title: 'Cities',
        emptyText: 'No city stats available yet.',
        onRetry: () async {
          await ref.read(countriesViewmodelProvider.notifier).refresh();
        },
        buildList: (data) {
          final items = data.citiesFlat;

          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No city stats available for this server yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final it = items[i];

              final subtitleParts = <String>[it.country];
              subtitleParts.add('${it.points} pts');
              subtitleParts.add(_formatDuration(it.stayedFor));

              return _DetailsTile(
                title: it.city,
                subtitle: subtitleParts.join(' • '),
                leading: Icons.location_city,
              );
            },
          );
        },
      ),
    );
  }

  void _openCountriesSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatsDetailsSheet(
        title: 'Countries',
        emptyText: 'No country stats available yet.',
        onRetry: () async {
          await ref.read(countriesViewmodelProvider.notifier).refresh();
        },
        buildList: (data) {
          final items = data.countries;

          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No country stats available for this server yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final it = items[i];
              final cityCount = it.cities.length;

              return _DetailsTile(
                title: it.country,
                subtitle: '$cityCount ${cityCount == 1 ? 'city' : 'cities'}',
                leading: Icons.public,
              );
            },
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds;

    if (totalSeconds <= 0) {
      return '0s';
    }

    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }

    return '${seconds}s';
  }

  String _formatLastSync(BuildContext context, DateTime? lastSyncedAtUtc) {
    if (lastSyncedAtUtc == null) {
      return 'Last sync: never';
    }

    final local = lastSyncedAtUtc.toLocal();
    final now = DateTime.now();

    final diff = now.difference(local);

    if (diff.inSeconds < 30) {
      return 'Last sync: just now';
    }
    if (diff.inMinutes < 60) {
      return 'Last sync: ${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return 'Last sync: ${diff.inHours}h ago';
    }

    final locale = Localizations.localeOf(context).toString();
    final df = DateFormat.yMMMd(locale).add_Hm();
    return 'Last sync: ${df.format(local)}';
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTappable = onTap != null;
    final theme = Theme.of(context);

    final card = Card(
      elevation: isTappable ? 14 : 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isTappable
            ? BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.28),
        )
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
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
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isTappable) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    if (!isTappable) {
      return card;
    }

    return InkWell(
      onTap: onTap,
      child: card,
    );
  }
}

class _StatsDetailsSheet extends ConsumerWidget {
  final String title;
  final String emptyText;
  final Widget Function(VisitedCountriesUiModel data) buildList;
  final Future<void> Function() onRetry;

  const _StatsDetailsSheet({
    required this.title,
    required this.emptyText,
    required this.buildList,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(countriesViewmodelProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.40,
      maxChildSize: 0.92,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            gradient: Theme.of(context).pageBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: async.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _StatsDetailsError(
                    error: e,
                    onRetry: onRetry,
                  ),
                  data: (result) {
                    if (result case Ok(value: final VisitedCountriesUiModel? data)) {
                      if (data == null) {
                        return Center(child: Text(emptyText));
                      }

                      return PrimaryScrollController(
                        controller: controller,
                        child: buildList(data),
                      );
                    }

                    if (result case Err(value: final Failure failure)) {
                      return _StatsDetailsError(
                        error: failure,
                        onRetry: onRetry,
                      );
                    }

                    return Center(child: Text(emptyText));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatsDetailsError extends StatelessWidget {
  final Object error;
  final Future<void> Function()? onRetry;

  const _StatsDetailsError({
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final message = switch (error) {
      Failure f => _friendlyFailureMessage(f),
      _ => error.toString(),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await onRetry!();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _friendlyFailureMessage(Failure f) {
    final statusCode = f.context['statusCode'];
    if (statusCode == 502) {
      return 'Server is temporarily unavailable (502). Try again in a bit.';
    }
    return f.message;
  }
}

class _DetailsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leading;

  const _DetailsTile({
    required this.title,
    required this.subtitle,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
          child: Icon(leading),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}