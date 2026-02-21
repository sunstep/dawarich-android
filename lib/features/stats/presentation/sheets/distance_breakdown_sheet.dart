import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:dawarich/features/stats/presentation/helpers/stats_period_snapshot.dart';
import 'package:dawarich/features/stats/presentation/models/stats/monthly_stats_uimodel.dart';
import 'package:dawarich/features/stats/presentation/providers/derived/all_time_monthly_distance_provider.dart';
import 'package:dawarich/features/stats/presentation/providers/stats_period_breakdown_provider.dart';
import 'package:dawarich/features/stats/presentation/viewmodels/stats_viewmodel.dart';
import 'package:dawarich/features/stats/presentation/widgets/monthly_distance_card.dart';
import 'package:dawarich/features/stats/presentation/widgets/year_over_year_distance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DistanceBreakdownSheet extends ConsumerWidget {
  const DistanceBreakdownSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsViewmodelProvider);
    final breakdownYear = ref.watch(statsBreakdownYearProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.80,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            gradient: Theme.of(context).pageBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _SheetHandle(),
              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(child: Text(
                        'Distance breakdown',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),)
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
                child: statsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _SheetError(
                    errorText: e.toString(),
                    onRetry: () =>
                        ref.read(statsViewmodelProvider.notifier).refresh(),
                  ),
                  data: (stats) {
                    if (stats == null) {
                      return _SheetEmpty(
                        controller: controller,
                        text: 'No distance stats available yet.',
                      );
                    }

                    final years = availableYears(stats);
                    final snapshot = resolveStatsForYear(
                      stats: stats,
                      selectedYear: breakdownYear,
                    );

                    final allTimeMonthly = ref.watch(allTimeMonthlyDistanceProvider);

                    final MonthlyStatsUiModel? monthly = snapshot.isYearMode
                        ? snapshot.monthlyDistance
                        : allTimeMonthly;

                    if (monthly == null) {
                      return _SheetEmpty(
                        controller: controller,
                        text: 'No monthly distance data available.',
                      );
                    }

                    return PrimaryScrollController(
                      controller: controller,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: [
                          const SizedBox(height: 12),

                          YearOverYearDistanceCard(
                            stats: stats,
                            selectedYear: breakdownYear,
                            onYearSelected: (v) => ref.read(statsBreakdownYearProvider.notifier).setYear(v),
                          ),

                          const SizedBox(height: 16),

                          MonthlyDistanceCard(
                            availableYears: years,
                            selectedYear: breakdownYear,
                            onYearChanged: (v) => ref
                                .read(statsBreakdownYearProvider.notifier)
                                .setYear(v),
                            monthly: monthly,
                          ),
                        ],
                      ),
                    );
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

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _SheetError extends StatelessWidget {
  final String errorText;
  final VoidCallback onRetry;

  const _SheetError({
    required this.errorText,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(errorText, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetEmpty extends StatelessWidget {
  final ScrollController controller;
  final String text;

  const _SheetEmpty({
    required this.controller,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}